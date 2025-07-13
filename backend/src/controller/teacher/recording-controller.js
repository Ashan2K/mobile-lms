const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();

class RecordingController {
    async uploadRecording(req, res) {
        const {
            id, // Optional - for updates
            name,
            description,
            visibility,
            thumbnailUrl,
            videoUrl,
            uploadDate,
            batchId, // Optional
        } = req.body;

        if (!name || !description || !visibility || !videoUrl || !uploadDate) {
            return res.status(400).send({
                success: false,
                message: 'Missing required fields: name, description, visibility, videoUrl, and uploadDate are required',
            });
        }

        try {
            const recordingData = {
                name,
                description,
                visibility,
                thumbnailUrl: thumbnailUrl || null,
                videoUrl,
                batchId: batchId || null,
                uploadDate,
            };

            let recordingRef;
            if (id) {
                // Update existing
                recordingRef = db.collection('recordings').doc(id);
                await recordingRef.set(recordingData, { merge: true });
            } else {
                // Create new
                recordingRef = await db.collection('recordings').add(recordingData);
            }

            return res.status(200).send({
                success: true,
                message: 'Recording uploaded successfully',
                data: {
                    id: recordingRef.id,
                    ...recordingData
                },
            });
        } catch (error) {
            console.error('Error uploading recording:', error);
            return res.status(500).send({
                success: false,
                message: 'Failed to upload recording',
                error: error.message,
            });
        }
    }
    async getRecordings(req, res) {
        try {
            const recordingsSnapshot = await db.collection('recordings').get();
            const recordings = recordingsSnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data(),
            }));

            return res.status(200).send(recordings);
        } catch (error) {
            console.error('Error fetching recordings:', error);
            return res.status(500).send({
                success: false,
                message: 'Failed to fetch recordings',
                error: error.message,
            });
        }
    }
}

module.exports = new RecordingController();
