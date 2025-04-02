const express = require('express');
const router = express.Router();
const firebaseAuthController = require('../controller/firebase-auth-controller');
const { verifyToken } = require('../middleware/auth-middleware');
const { auth } = require('firebase-admin');

// Public routes
router.post('/register', firebaseAuthController.registerUser);
router.post('/login', firebaseAuthController.loginUser);
router.post('/logout', firebaseAuthController.logoutUser);
router.post('/reset-password', firebaseAuthController.resetPassword);
router.post('/verify-phone', firebaseAuthController.verifyPhoneNumber);
router.post('/send-otp',firebaseAuthController.sendOTP);
router.post('/verify-otp',firebaseAuthController.verifyOTP);

// Protected routes
router.get('/profile', verifyToken, firebaseAuthController.getUserProfile);
router.put('/profile', verifyToken, firebaseAuthController.updateUserProfile);

module.exports = router; 