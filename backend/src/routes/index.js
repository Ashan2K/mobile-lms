const express = require('express');
const router = express.Router();

const firebaseAuthController = require('../controller/firebase-auth-controller');
const studentManageController = require('../controller/teacher/student-manage-controller');
const courseController = require('../controller/teacher/course-controller');
const mockExamController = require('../controller/teacher/mockexam-controller');
const notificationController = require('../controller/teacher/notification-controller');
const recordingController = require('../controller/teacher/recording-controller');
const studentCourseController = require('../controller/student/student-course-controller');
const paymentController = require('../controller/payement/payment-controller');
const scheduleController = require('../controller/teacher/schedule-controller');
const userPro = require('../controller/student/user-profile');
const attendanceController = require('../controller/attendance/attendance-controller');
const studentProfileController = require('../controller/student/profile-controller');


router.post('/api/register', firebaseAuthController.registerUser);
router.post('/api/login', firebaseAuthController.loginUser);
router.post('/api/logout', firebaseAuthController.logoutUser);
router.post('/api/reset-password', firebaseAuthController.resetPassword);
router.post('/api/create-otp', firebaseAuthController.createOtp);
router.post('/api/verify-otp', firebaseAuthController.verifyOtp);
router.post('/api/load-student',studentManageController.loadStudent);
router.post('/api/block-student', studentManageController.blockUnblockStudent);
router.post('/api/getprofile',firebaseAuthController. getUserProfile);
router.post('/api/change-password', firebaseAuthController.changePassword);

router.post('/api/create-course', courseController.createCourse);
router.post('/api/load-course', courseController.loadCourse);

router.post('/api/create-questions', mockExamController.createQuestionsBank);
router.post('/api/get-question-set', mockExamController.getQuestionsBank);
router.post('/api/create-audio-questions', mockExamController.createAudioQuestionsBank);
router.post('/api/get-audio-question-set', mockExamController.getAudioQuestionsBank);
router.post('/api/create-mock-exam', mockExamController.createMockExam);
router.post('/api/get-mock-exams', mockExamController.getMockExams);
router.post('/api/question-banks/:id', mockExamController.getMcqBankbyId);
router.post('/api/audio-question-banks/:id', mockExamController.getAudioBankbyId);


router.post('/api/recordings-upload', recordingController.uploadRecording);
router.post('/api/get-recordings', recordingController.getRecordings);


router.post('/api/send-notification',notificationController.sendNotification);


router.post('/api/enroll-course', studentCourseController.enrollInCourse);
router.post('/api/get-enrollments', studentCourseController.getEnrollments);
router.post('/api/get-enrolled-courses', studentCourseController.getEnrolledCourses);
router.post('/api/coursebyid', studentCourseController.getCourseById);
router.post('/api/payment-history', studentCourseController.getPaymentHistory);


router.post('/api/create-payment-intent', paymentController.createPaymentIntent.bind(paymentController));
router.post('/api/pay-monthly-fee', paymentController.payMonthlyFee.bind(paymentController));
router.post('/api/record-monthly-payment',studentCourseController.payMonthlyFee);

//router.post('/api/get-due-payments', paymentController.getduePayments.bind(paymentController));

router.post('/api/create-schedule',scheduleController.createSchedule);
router.post('/api/get-schedules', scheduleController.getSchedules);

router.post('/api/get-studentById', userPro.getStudentById);
router.post('/api/get-course-payment-historyById', userPro.getCouserpayementHistoryById);
router.post('/api/get-course-due-paymentsById', userPro.getCourseDuepaymentsById);


router.post('/api/mark-attendance', attendanceController.markAttendance);
router.post('/api/get-attendance-of-user', attendanceController.getAttendanceOfUser);


router.post('/api/update-profile-pic', studentProfileController.updateProfilePicture);



module.exports = router;