const express = require('express');
const router = express.Router();
const firebaseAuthController = require('../controller/firebase-auth-controller');
const { verifyToken } = require('../middleware/auth-middleware');

// Public routes
router.post('/register', firebaseAuthController.registerUser);
router.post('/login', firebaseAuthController.loginUser);
router.post('/logout', firebaseAuthController.logoutUser);
router.post('/reset-password', firebaseAuthController.resetPassword);
router.post('/verify-phone', firebaseAuthController.verifyPhoneNumber);

// Protected routes
router.get('/profile', verifyToken, firebaseAuthController.getUserProfile);
router.put('/profile', verifyToken, firebaseAuthController.updateUserProfile);

module.exports = router; 