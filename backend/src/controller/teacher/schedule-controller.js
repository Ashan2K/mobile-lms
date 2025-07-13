const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();

const NotificationController = require('./notification-controller');

class ScheduleController {

    async createSchedule(req, res) {
        const {
            title,
            description,
            date,
            time,
            classType,
            zoomLink,
            courseId,
            courseName,
            currentStudents,
            createdAt,
            updatedAt,
           
        } = req.body;

    
        if (!title || !date || !time || !courseId || !courseName) {
            return res.status(400).json({ error: 'Title, date, time, courseId, and courseName are required' });
        }

        try {
            const scheduleRef = db.collection('schedules').doc();
            const scheduleData = {
                id: scheduleRef.id, // Use Firestore's auto-generated ID
                title,
                description,
                date: new Date(date),
                time,
                classType,
                zoomLink,
                courseId,
                courseName,
                currentStudents: currentStudents || 0,
                createdAt: createdAt || admin.firestore.Timestamp.now(),
                updatedAt: updatedAt || admin.firestore.Timestamp.now(),
        
            };

            await scheduleRef.set(scheduleData);

            const tokens = await NotificationController.getUserTokensByRole('student');
            if (tokens.length > 0) {
                await NotificationController.multicastNotifications(
                    tokens,
                    `Class Scheduled: ${title}`,
                    `There is a new class scheduled for ${courseName} on ${date} at ${time}.`,
                    {
                        scheduleId: scheduleRef.id,
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    }
                );
            }


            res.status(201).json({ message: 'Schedule created successfully', id: scheduleRef.id });
        }
        catch (error) {
            console.error('Error creating schedule:', error);
            res.status(500).json({ error: 'Failed to create schedule' });
        }

    }

    async getSchedules(req, res) {
        try {
            const schedulesSnapshot = await db.collection('schedules').get();
            const schedules = schedulesSnapshot.docs.map(doc => doc.data());
            res.status(200).json(schedules);
        } catch (error) {
            console.error('Error fetching schedules:', error);
            res.status(500).json({ error: 'Failed to fetch schedules' });
        }
    }   

}

module.exports = new ScheduleController();