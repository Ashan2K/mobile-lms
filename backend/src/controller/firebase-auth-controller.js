const {
  getAuth,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
  sendPasswordResetEmail,
  PhoneAuthProvider,
  signInWithCredential
} = require('../config/firebase');

const { admin } = require('../config/firebase');
const e = require('express');
require('../config/twilio');





const client = twilio(twilioConfig.accountSid, twilioConfig.authToken);

const auth = getAuth();

class FirebaseAuthController {
  // Register User (Step 1)
  registerUser = async (req, res) =>{
    const { fname, lname, email, phoneNumber, password, role } = req.body;

    // Validate input data
    if (!email || !password || !fname || !lname || !role || !phoneNumber) {
      return res.status(422).json({ error: "All fields are required" });
    }

    try {
      let formattedPhoneNumber = phoneNumber.startsWith('+') ? phoneNumber : `+${phoneNumber}`;

      // Create user with Firebase Admin
      const userRecord = await admin.auth().createUser({
        email,
        phoneNumber: formattedPhoneNumber,
        password,
        disabled: true // User remains disabled until OTP verification
      });

      const studentId = await this.generateStudentId();

      // Save user data to Firestore
      await admin.firestore().collection('users').doc(userRecord.uid).set({
        fname,
        lname,
        email,
        phoneNumber: formattedPhoneNumber,
        role,
        studentId,
        status:'active',
        imageUrl: null,
        emailVerified: true,
        phoneVerified: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });

      return res.status(200).json({
        message: "User registered successfully. OTP required for activation.",
        data: { uid: userRecord.uid, phoneNumber: formattedPhoneNumber }
      });

    } catch (error) {
      console.error('Registration error:', error);
      return res.status(500).json({ error: error.message });
    }
  }

  // Function to generate auto-incrementing studentId
  async generateStudentId() {
    const studentIdDocRef = admin.firestore().collection('settings').doc('studentIdCounter');

    try {
      // Use a Firestore transaction to ensure atomic updates
      const studentId = await admin.firestore().runTransaction(async (transaction) => {
        const doc = await transaction.get(studentIdDocRef);
        if (!doc.exists) {
          // If the document does not exist, create it with an initial value
          transaction.set(studentIdDocRef, { currentId: 1000 });
          return 1000; // Starting value
        }

        const currentId = doc.data().currentId;
        const newStudentId = currentId + 1;

        // Update the counter for the next studentId
        transaction.update(studentIdDocRef, { currentId: newStudentId });

        return newStudentId;
      });

      return `KSTD${studentId}`;

    } catch (error) {
      console.error('Error generating studentId:', error);
      throw new Error('Error generating student ID');
    }
  }

  // Verify Phone Number (Step 2)
  async createOtp(req, res) {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ error: "Phone number is required" });
    }

    // Generate a random 6-digit OTP
    const otp = crypto.randomInt(100000, 999999).toString();

    // Store OTP in Firestore or your database (make sure it's stored temporarily)
    try {
      const otpExpireTime = Date.now() + 5 * 60 * 1000; // OTP expires in 5 minutes
      await admin.firestore().collection('otps').doc(phoneNumber).set({
        otp,
        expireAt: otpExpireTime
      });

      // Send OTP via Twilio
      await client.messages.create({
        body: `Your OTP is ${otp}. It is valid for 5 minutes.`,
        from: twilioConfig.fromNumber,
        to: phoneNumber
      });

      return res.status(200).json({
        message: "OTP sent successfully."
      });
    } catch (error) {
      console.error("Error generating OTP:", error);
      return res.status(500).json({ error: "Failed to send OTP" });
    }
  }

  verifyPhoneNumber(req, res) {
    const { verificationId, verificationCode } = req.body;
    if (!verificationId || !verificationCode) {
      return res.status(422).json({
        verificationId: "Verification ID is required",
        verificationCode: "Verification code is required"
      });
    }

    const credential = PhoneAuthProvider.credential(verificationId, verificationCode);
    signInWithCredential(auth, credential)
      .then((userCredential) => {
        res.status(200).json({ message: "Phone number verified successfully!" });
      })
      .catch((error) => {
        console.error(error);
        res.status(500).json({ error: "Error verifying phone number" });
      });
  }

  loginUser(req, res) {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(422).json({
        email: "Email is required",
        password: "Password is required",
      });
    }

    signInWithEmailAndPassword(auth, email, password)
      .then(async (userCredential) => {
        try {
          // Get user document from Firestore
          const userDoc = await admin.firestore()
            .collection('users')
            .doc(userCredential.user.uid)
            .get();

          if (!userDoc.exists) {
            return res.status(404).json({ error: "User document not found" });
          }

          const userData = userDoc.data();
          
          // Create custom token
          const customToken = await admin.auth().createCustomToken(userCredential.user.uid, {
            role: userData.role
          });

          // Set HTTP-only cookie with the token
          res.cookie('access_token', customToken, {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'strict',
            maxAge: 24 * 60 * 60 * 1000 // 24 hours
          });

          res.status(200).json({ 
            message: "User logged in successfully",
            user: userData,
            token: customToken // Also send token in response body
          });
        } catch (error) {
          console.error(error);
          res.status(500).json({ error: "Error fetching user data" });
        }
      })
      .catch((error) => {
        console.error(error);
        const errorMessage = error.message || "An error occurred while logging in";
        res.status(500).json({ error: errorMessage });
      });
  }

  logoutUser(req, res) {
    signOut(auth)
      .then(() => {
        res.clearCookie('access_token');
        res.status(200).json({ message: "User logged out successfully" });
      })
      .catch((error) => {
        console.error(error);
        res.status(500).json({ error: "Internal Server Error" });
      });
  }

  resetPassword(req, res) {
    const { email } = req.body;
    if (!email) {
      return res.status(422).json({
        email: "Email is required"
      });
    }
    
    sendPasswordResetEmail(auth, email)
      .then(() => {
        res.status(200).json({ message: "Password reset email sent successfully!" });
      })
      .catch((error) => {
        console.error(error);
        res.status(500).json({ error: "Internal Server Error" });
      });
  }

  getUserProfile(req, res) {
    const userId = req.user.uid; // Assuming you have middleware that adds user to req

    admin.firestore()
      .collection('users')
      .doc(userId)
      .get()
      .then((doc) => {
        if (!doc.exists) {
          return res.status(404).json({ error: "User not found" });
        }
        res.status(200).json(doc.data());
      })
      .catch((error) => {
        console.error(error);
        res.status(500).json({ error: "Error fetching user profile" });
      });
  }

  updateUserProfile(req, res) {
    const userId = req.user.uid; // Assuming you have middleware that adds user to req
    const { fname, lname, phoneNumber } = req.body;

    const updateData = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    if (fname) updateData.fname = fname;
    if (lname) updateData.lname = lname;
    if (phoneNumber) updateData.phoneNumber = phoneNumber;

    admin.firestore()
      .collection('users')
      .doc(userId)
      .update(updateData)
      .then(() => {
        res.status(200).json({ message: "User profile updated successfully" });
      })
      .catch((error) => {
        console.error(error);
        res.status(500).json({ error: "Error updating user profile" });
      });
  }
}

module.exports = new FirebaseAuthController();

