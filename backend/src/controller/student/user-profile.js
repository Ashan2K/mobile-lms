
const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();

class UserProfileController {
    async getStudentById(req, res) {
        try {
            const userId = req.body.userId; // Extract user ID from the request parameters
            if (!userId) {
                return res.status(400).send('User ID is required');
            }

            const userRef = db.collection('users').doc(userId); // Reference to the user document
            const userDoc = await userRef.get(); // Fetch the user document

            if (!userDoc.exists) {
                return res.status(404).send('User not found'); // If no user found, send 404
            }

            const userData = userDoc.data(); // Extract data from the document

            // Map Firestore data to the required frontend format
            const mappedUser = {
                uid: userDoc.id,
                stdId: userData.stdId,
                imageUrl: userData.imageUrl,
                status: userData.status,
                fname: userData.fname,
                lname: userData.lname,
                email: userData.email,
                role: userData.role ? userData.role.toString().split('.').pop() : undefined,
                phoneNumber: userData.phoneNumber,
                qrCodeUrl: userData.qrCode,
            };

            res.status(200).json(mappedUser); // Send the mapped user data as JSON response

        } catch (error) {
            console.error('Error fetching user profile: ', error); // Log the error to help with debugging
            res.status(500).send('Error fetching user profile'); // Send error response
        }
    }

    async getCouserpayementHistoryById(req, res) {
        try {
            const { userId, courseId } = req.body;
            if (!userId || !courseId) {
                return res.status(400).send('User ID and Course ID are required');
            }

            const paymentsRef = db.collection('payments');
            const querySnapshot = await paymentsRef
                .where('userId', '==', userId)
                .where('courseId', '==', courseId)
                .get();

            if (querySnapshot.empty) {
                return res.status(404).send('No payment history found');
            }

            const paymentHistory = [];
            querySnapshot.forEach(doc => {
                paymentHistory.push({ id: doc.id, ...doc.data() });
            });

            res.status(200).json(paymentHistory);
        } catch (error) {
            console.error('Error fetching payment history: ', error);
            res.status(500).send('Error fetching payment history');
        }
    }

    async getCourseDuepaymentsById(req, res) {
        try {
            const { userId, courseId } = req.body;
            if (!userId || !courseId) {
                return res.status(400).send('User ID and Course ID are required');
            }

            // Fetch enrollment document
            const enrollmentRef = db.collection('enrollments')
                .where('userId', '==', userId)
                .where('courseId', '==', courseId);
            const enrollmentSnap = await enrollmentRef.get();

            if (enrollmentSnap.empty) {
                return res.status(404).send('Enrollment not found');
            }

            const enrollmentDoc = enrollmentSnap.docs[0];
            const enrollmentData = enrollmentDoc.data();

            // Get paid months
            const paidMonths = Array.isArray(enrollmentData.paidMonths) ? enrollmentData.paidMonths : [];

            // Get enrolledAt date
            const enrolledAt = enrollmentData.enrolledAt?._seconds
                ? new Date(enrollmentData.enrolledAt._seconds * 1000)
                : null;

            if (!enrolledAt) {
                return res.status(400).send('Invalid enrollment date');
            }

            // Get current month in YYYY-MM format
            const now = new Date();
            const currentMonth = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0');

            // Build all months from enrolledAt to currentMonth
            const months = [];
            let year = enrolledAt.getFullYear();
            let month = enrolledAt.getMonth() + 1;
            const [currYear, currMonth] = currentMonth.split('-').map(Number);

            while (year < currYear || (year === currYear && month <= currMonth)) {
                months.push(`${year}-${String(month).padStart(2, '0')}`);
                month++;
                if (month > 12) {
                    month = 1;
                    year++;
                }
            }

            // Find due months (not in paidMonths)
            const dueMonths = months.filter(m => !paidMonths.includes(m));

            res.status(200).json({ dueMonths });
        } catch (error) {
            console.error('Error fetching due payments: ', error);
            res.status(500).send('Error fetching due payments');
        }

    }
 
}

module.exports = new UserProfileController();
