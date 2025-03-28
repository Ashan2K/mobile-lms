const {
  getAuth,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
  sendPasswordResetEmail,
  PhoneAuthProvider,
  signInWithCredential
} = require('../config/firebase');

const auth = getAuth();

class FirebaseAuthController {
  registerUser(req, res) {
    const { fname, lname, email, password, phoneNumber } = req.body;
    if (!email || !password || !phoneNumber) {
      return res.status(422).json({
        email: "Email is required",
        password: "Password is required",
        phoneNumber: "Phone number is required"
      });
    }

    // Create user with email and password
    createUserWithEmailAndPassword(auth, email, password)
      .then((userCredential) => {
        // Send phone verification
        const phoneProvider = new PhoneAuthProvider(auth);
        phoneProvider.verifyPhoneNumber(phoneNumber)
          .then((verificationId) => {
            res.status(201).json({ 
              message: "Verification code sent! Please verify your phone number.",
              verificationId 
            });
          })
          .catch((error) => {
            console.error(error);
            res.status(500).json({ error: "Error sending phone verification" });
          });
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
      .then((userCredential) => {
        const idToken = userCredential._tokenResponse.idToken
        if (idToken) {
          res.cookie('access_token', idToken, {
            httpOnly: true
          });
          res.status(200).json({ message: "User logged in successfully", userCredential });
        } else {
          res.status(500).json({ error: "Internal Server Error" });
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

}

module.exports = new FirebaseAuthController();

