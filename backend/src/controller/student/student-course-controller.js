const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();

class StudentCourseController {
    async enrollInCourse(req, res) {
        try {
            const { courseId, userId } = req.body; // Extract course ID and user ID from the request body

            if (!courseId || !userId) {
                return res.status(400).send('Course ID and User ID are required');
            }

            const now = new Date();
            const currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;


            const enrollmentRef = db.collection('enrollments').doc();
            await enrollmentRef.set({
                courseId,
                userId,
                enrolledAt: admin.firestore.FieldValue.serverTimestamp(),
                paidMonths: [currentMonth], // Store the current month as paid
            });

            res.status(200).send('Enrollment successful'); // Send success response

        } catch (error) {
            console.error('Error enrolling in course: ', error); // Log the error to help with debugging
            res.status(500).send('Error enrolling in course'); // Send error response
        }
    }

    async getEnrollments(req, res) {
        try {
            const userId = req.body.userId; // Extract user ID from the request body
            if (!userId) {
                return res.status(400).send('User ID is required');
            }
            const enrollmentsSnapshot = await db.collection('enrollments')
                .where('userId', '==', userId)
                .get();
            if (enrollmentsSnapshot.empty) {
                return res.status(404).send('No enrollments found for this user');
            }
            const enrollments = [];
            enrollmentsSnapshot.forEach(doc => {
                enrollments.push({ id: doc.id, ...doc.data() });
            });
            res.status(200).json(enrollments); // Send the list of enrollments as JSON response
        }
        catch (error) {
            console.error('Error fetching enrollments: ', error); // Log the error to help with
            res.status(500).send('Error fetching enrollments'); // Send error response
        }
    }


    async getEnrolledCourses(req, res) {
        try {
            const userId = req.body.userId; // Extract user ID from the request body

            if (!userId) {
                return res.status(400).send('User ID is required');
            }

            const enrollmentsSnapshot = await db.collection('enrollments')
                .where('userId', '==', userId)
                .get();

            if (enrollmentsSnapshot.empty) {
                return res.status(404).send('No courses found for this user');
            }

            const courses = [];
            enrollmentsSnapshot.forEach(doc => {
                courses.push({ id: doc.id, ...doc.data() });
            });

            res.status(200).json(courses); // Send the list of enrolled courses as JSON response

        } catch (error) {
            console.error('Error fetching enrolled courses: ', error);
            res.status(500).send('Error fetching enrolled courses');
        }
    }

    async getCourseById(req, res) {
        try {
            const courseId = req.body.id; // Extract course ID from the request parameters

            if (!courseId) {
                return res.status(400).send('Course ID is required');
            }

            const courseRef = db.collection('courses').doc(courseId);
            const courseDoc = await courseRef.get();

            if (!courseDoc.exists) {
                return res.status(404).send('Course not found');
            }

            res.status(200).json({ id: courseDoc.id, ...courseDoc.data() }); // Send the course data as JSON response

        } catch (error) {
            console.error('Error fetching course by ID: ', error);
            res.status(500).send('Error fetching course by ID');
        }
    }

    async payMonthlyFee(req, res) {
        try {
            const { courseId, userId, amount, month } = req.body; // Extract course ID, user ID, and amount from the request body

            if (!courseId || !userId || !amount) {
                return res.status(400).send('Course ID, User ID, and Amount are required');
            }

            const now = new Date();
            const currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;

            const enrollmentRef = db.collection('enrollments')
                .where('courseId', '==', courseId)
                .where('userId', '==', userId);

            const enrollmentSnapshot = await enrollmentRef.get();

            if (enrollmentSnapshot.empty) {
                return res.status(404).send('Enrollment not found');
            }

            const enrollmentDoc = enrollmentSnapshot.docs[0];
            const paidMonths = enrollmentDoc.data().paidMonths || [];

            if (paidMonths.includes(month)) {
                return res.status(400).send('Payment for this month has already been made');
            }

            paidMonths.push(month); // Add the current month to the list of paid months

            await enrollmentDoc.ref.update({ paidMonths }); // Update the enrollment document with the new paid month

            // add payment record to payments collection
            const paymentRef = db.collection('payments').doc();
            await paymentRef.set({
                courseId,
                userId,
                amount,
                month: month,
                paidAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Send success response
            console.log(`Payment of ${amount} for course ${courseId} by user ${userId} processed successfully`);

            res.status(200).send('Payment successful'); // Send success response

        } catch (error) {
            console.error('Error processing payment: ', error);
            res.status(500).send('Error processing payment');
        }
    }
    async getPaymentHistory(req, res) {
        try {
            const userId = req.body.userId; // Extract user ID from the request body

            if (!userId) {
                return res.status(400).send('User ID is required');
            }

            const paymentsSnapshot = await db.collection('payments')
                .where('userId', '==', userId)
                .get();

            if (paymentsSnapshot.empty) {
                return res.status(404).send('No payment history found for this user');
            }

            const paymentHistory = [];
            paymentsSnapshot.forEach(doc => {
                paymentHistory.push({ id: doc.id, ...doc.data() });
            });

            res.status(200).json(paymentHistory); // Send the payment history as JSON response

        } catch (error) {
            console.error('Error fetching payment history: ', error);
            res.status(500).send('Error fetching payment history');
        }
    }
}

module.exports = new StudentCourseController(); 