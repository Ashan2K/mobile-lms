const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();

class StudentManageController {
    async loadStudent(req, res) {
        try {
            const usersRef = db.collection('users');
            const snapshot = await usersRef.where('role', '==', 'student').get(); // Query for users with the role "student"
            
            if (snapshot.empty) {
                return res.status(404).send('No student users found');
            }
            
            // Map each document to a user object with the desired fields
            const users = snapshot.docs.map(doc => {
                const data = doc.data(); // Extract the data from the document
                return {
                    uid: doc.id, // Use the document ID as the UID
                    email: data.email,
                    phoneNumber: data.phoneNumber,
                    fname: data.fname,
                    lname: data.lname,
                    role: data.role,
                    status: data.status,
                    stdId: data.studentId,
                    imageUrl: data.imageUrl,
                };
            });
            
            res.json(users); // Send the filtered list of student users

        } catch (error) {
            // Log the error to help with debugging
            console.error('Error fetching students: ', error);
            res.status(500).send('Error loading student users');
        }
    }

    async blockUnblockStudent(req, res) {
        try {
            const { uid } = req.body; // Extract the UID from the request body

            if (!uid) {
                return res.status(400).send('User ID is required');
            }

            // Update the user's status to "blocked" in Firestore
            const status = await db.collection('users').doc(uid).get().then(doc => doc.data().status);
            console.log('Current status:', status); // Log the current status for debugging

            if(status === 'blocked'){
                await db.collection('users').doc(uid).update({ status: 'active' });
                res.status(200).send('Student active successfully');
            }
            else{
                await db.collection('users').doc(uid).update({ status: 'blocked' });
                res.status(200).send('Student blocked successfully');
            }

            
        } catch (error) {
            console.error('Error blocking student: ', error);
            res.status(500).send('Error blocking student');
        }
    }
}

module.exports = new StudentManageController();
