const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();

class AttendanceController {

    async markAttendance(req, res) {
        const { courseId, date } = req.body;

        if (!courseId || !date) {
            return res.status(400).json({ message: 'courseId and date are required' });
        }

        try {
            // Get all students enrolled in the course
            const enrollmentsSnapshot = await db.collection('enrollments')
                .where('courseId', '==', courseId)
                .get();

            if (enrollmentsSnapshot.empty) {
                return res.status(404).json({ message: 'No students enrolled in this course' });
            }

            // Prepare attendance records (default absent)
            const batch = db.batch();
            enrollmentsSnapshot.forEach(doc => {
                const studentId = doc.data().userId;
                const attendanceRef = db.collection('attendance')
                    .doc(`${courseId}_${date}_${studentId}`);
                batch.set(attendanceRef, {
                    courseId,
                    date,
                    studentId,
                    status: 'absent'
                }, { merge: true });
            });

            await batch.commit();

            // Mark the specific user as present
            const { studentId } = req.body;
            if (studentId) {
                const attendanceRef = db.collection('attendance')
                    .doc(`${courseId}_${date}_${studentId}`);
                await attendanceRef.set({
                    courseId,
                    date,
                    studentId,
                    status: 'present'
                }, { merge: true });
            }

            res.status(200).json({ message: 'Attendance marked successfully' });
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }

    async getAttendanceOfUser(req, res) {
        const { courseId, studentId } = req.body;

        if (!courseId || !studentId) {
            return res.status(400).json({ message: 'courseId and studentId are required' });
        }

        try {
            const attendanceSnapshot = await db.collection('attendance')
                .where('courseId', '==', courseId)
                .where('studentId', '==', studentId)
                .get();

            if (attendanceSnapshot.empty) {
                return res.status(404).json({ message: 'No attendance records found for this user' });
            }

            const attendanceRecords = [];
            attendanceSnapshot.forEach(doc => {
                attendanceRecords.push({ id: doc.id, ...doc.data() });
            });

            res.status(200).json(attendanceRecords);
        } catch (error) {
            res.status(500).json({ message: error.message });
        }
    }
}

module.exports = new AttendanceController();