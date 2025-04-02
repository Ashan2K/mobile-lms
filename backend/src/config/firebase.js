require("dotenv").config();
const firebase = require("firebase/app");
const functions = require('firebase-functions');

const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.FIREBASE_APP_ID
};

firebase.initializeApp(firebaseConfig);

const admin = require('firebase-admin');
const serviceAccount = require("../firebaseService.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

exports.enableUserAfterVerification = functions.https.onCall(async (data, context) => {
  const userId = data.uid;

  try {
    // Enable the user or perform any other necessary actions.
    await admin.auth().updateUser(userId, { disabled: false });
    return { success: true };
  } catch (error) {
    console.error('Error enabling user:', error);
    throw new functions.https.HttpsError('internal', 'Unable to enable user');
  }
});

const {
  getAuth,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
  signOut,
  sendPasswordResetEmail,
  PhoneAuthProvider,
  signInWithCredential
} = require("firebase/auth");

module.exports = {
  getAuth,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
  signOut,
  sendPasswordResetEmail,
  PhoneAuthProvider,
  signInWithCredential,
  admin
};