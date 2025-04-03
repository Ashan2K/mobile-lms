const express = require('express');
const router = express.Router();

const firebaseAuthController = require('../controller/firebase-auth-controller');
const studentManageController = require('../controller/teacher/student-manage-controller');


router.post('/api/register', firebaseAuthController.registerUser);
router.post('/api/login', firebaseAuthController.loginUser);
router.post('/api/logout', firebaseAuthController.logoutUser);
router.post('/api/reset-password', firebaseAuthController.resetPassword);
router.post('/api/create-otp', firebaseAuthController.createOtp);
router.post('/api/verify-otp', firebaseAuthController.verifyOtp);
router.post('/api/load-student',studentManageController.loadStudent);
router.post('/api/block-student', studentManageController.blockUnblockStudent);
router.post('/api/getprofile',firebaseAuthController. getUserProfile);




module.exports = router;