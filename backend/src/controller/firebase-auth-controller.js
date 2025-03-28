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

const auth = getAuth();

class FirebaseAuthController {
  registerUser(req, res) {
    const { fname, lname, email, password, phoneNumber, role } = req.body;
    
    if (!email || !password || !fname || !lname || !role) {
      return res.status(422).json({
        email: "Email is required",
        password: "Password is required",
        fname: "First name is required",
        lname: "Last name is required",
        role: "Role is required"
      });
    }

    // Create user with email and password
    createUserWithEmailAndPassword(auth, email, password)
      .then(async (userCredential) => {
        try {
          // Create user document in Firestore
          await admin.firestore().collection('users').doc(userCredential.user.uid).set({
            id: userCredential.user.uid,
            fname,
            lname,
            email,
            role,
            phoneNumber: phoneNumber || null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          });

          // Send phone verification if phone number is provided
          if (phoneNumber) {
            const phoneProvider = new PhoneAuthProvider(auth);
            phoneProvider.verifyPhoneNumber(phoneNumber)
              .then((verificationId) => {
                res.status(201).json({ 
                  message: "User created and verification code sent! Please verify your phone number.",
                  verificationId,
                  user: {
                    id: userCredential.user.uid,
                    fname,
                    lname,
                    email,
                    role,
                    phoneNumber
                  }
                });
              })
              .catch((error) => {
                console.error(error);
                res.status(500).json({ error: "Error sending phone verification" });
              });
          } else {
            res.status(201).json({
              message: "User created successfully!",
              user: {
                id: userCredential.user.uid,
                fname,
                lname,
                email,
                role,
                phoneNumber: null
              }
            });
          }
        } catch (error) {
          console.error(error);
          res.status(500).json({ error: "Error creating user document" });
        }
      })
      .catch((error) => {
        const errorMessage = error.message || "An error occurred while registering user";
        res.status(500).json({ error: errorMessage });
      });
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

