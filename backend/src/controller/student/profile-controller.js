const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();

class ProfileController{

    async updateProfilePicture(req, res) {
        try {
            const { userId, fileUrl } = req.body;
            
            if (!userId || !fileUrl) {
                return res.status(400).send('User ID and file URL are required');
            }

            // Update the user's profile in Firestore
            const userRef = db.collection('users').doc(userId);
            console.log(userRef.id);
            await userRef.update({ imageUrl: fileUrl });

            res.status(200).json({ message: 'Profile picture updated successfully',fileUrl });
        } catch (error) {
            console.error('Error updating profile picture: ', error);
            res.status(500).send('Error updating profile picture');
        }
    }
}

module.exports = new ProfileController();