const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();
const NotificationController = require('./notification-controller'); 

class CourseController {
    async createCourse(req, res) {
        try {
            const { courseName, courseCode, description, status, schedule, startDate, price } = req.body; // Extract course details from the request body

            if (!courseName || !courseCode || !description || !status || !schedule || !startDate) {
                return res.status(400).send('All fields are required');
            }

            const courseRef = db.collection('courses').doc(); // Create a new document reference in the "courses" collection
            await courseRef.set({
                courseName,
                courseCode,
                description,
                status,
                schedule,
                startDate,
                price,
                createdAt: admin.firestore.FieldValue.serverTimestamp(), 
            });

            const tokens = await NotificationController.getUserTokensByRole('student');

            if (tokens.length > 0) {
                await NotificationController.multicastNotifications(
                    tokens,
                    'New Course Available',
                    `A new course "${courseName}" has been created.`,
                    {
                        courseId: courseRef.id,
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    }
                );
            }
            
            res.status(200).send('Course created successfully'); // Send success response

        } catch (error) {
            console.error('Error creating course: ', error); // Log the error to help with debugging
            res.status(500).send('Error creating course'); // Send error response
        }
    }

    async loadCourse(req, res) {
        try {
            const coursesRef = db.collection('courses');
            const snapshot = await coursesRef.get(); // Query for all courses

            if (snapshot.empty) {
                return res.status(404).send('No courses found');
            }

            // Map each document to a course object with the desired fields
            const courses = snapshot.docs.map(doc => {
                const data = doc.data(); // Extract the data from the document
                return {
                    courseId: doc.id, // Use the document ID as the course ID
                    courseName: data.courseName,
                    courseCode: data.courseCode,
                    description: data.description,
                    status: data.status,
                    schedule: data.schedule,
                    startDate: data.startDate,
                    price: data.price,
                    createdAt: data.createdAt,
                };
            });

            res.status(200).json(courses); // Send the filtered list of courses

        } catch (error) {
            // Log the error to help with debugging
            console.error('Error fetching courses: ', error);
            res.status(500).send('Error loading courses');
        }
    }
}
module.exports = new CourseController(); // Export an instance of the CourseController class