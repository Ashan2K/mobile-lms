const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();

class NotificationController {
    sendNotification = async (req, res) => {
        const { targetRole, title, body, data = {} } = req.body;
        
        if (!targetRole || !title || !body) {
            return res.status(400).send({
                success: false,
                message: 'Missing required fields: targetRole, title, and body are required',
            });
        }

        try {
            const tokens = await this.getUserTokensByRole(targetRole);

            if (tokens.length === 0) {
                return res.status(404).send({
                    success: false,
                    message: 'No users found with the specified role.',
                });
            }

            await this.multicastNotifications(tokens, title, body, data);

            res.status(200).send({
                success: true,
                message: 'Notification sent successfully',
                recipients: tokens.length
            });
        } catch (error) {
            console.error('Notification error:', error);
            res.status(500).send({
                success: false,
                message: 'Failed to send notification',
                error: error.message,
            });
        }
    };

    async multicastNotifications(tokens, title, body, data) {
        try {
            const message = {
                notification: {
                    title: title,
                    body: body,
                },
                data: {
                    ...data,
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                    
                },
                android: {
                    notification: {
                        sound: "default",
                        priority: "high",
                        channelId: "default",
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: "default",
                            badge: 1,
                        },
                    },
                }
            };

            // Send notifications to each token individually
            const promises = tokens.map(token => 
                admin.messaging().send({
                    ...message,
                    token: token
                })
            );

            const results = await Promise.allSettled(promises);
            
            // Track successful and failed sends
            const failedTokens = [];
            let successCount = 0;

            results.forEach((result, index) => {
                if (result.status === 'fulfilled') {
                    successCount++;
                } else {
                    failedTokens.push(tokens[index]);
                    console.error(`Failed to send to token ${tokens[index]}:`, result.reason);
                }
            });

            if (failedTokens.length > 0) {
                console.error('Failed to send to tokens:', failedTokens);
            }

            console.log(`Successfully sent notifications to ${successCount} devices`);
            await this.saveNotification(title, body);
        } catch (err) {
            console.error("Error sending notifications:", err);
            throw err;
        }
    }

    async getUserTokensByRole(role) {
        try {
            const usersRef = db.collection('users');
            const snapshot = await usersRef.where('role', '==', role).get();

            if (snapshot.empty) {
                console.log('No users found with the specified role');
                return [];
            }

            const tokens = [];
            snapshot.forEach(doc => {
                const user = doc.data();
                if (user.fcmToken) {
                    tokens.push(user.fcmToken);
                }
            });

            return tokens;
        } catch (error) {
            console.error('Error getting user tokens:', error);
            throw error;
        }
    }

    async saveNotification( title, body) {
        try {
            const docRef = db.collection('notifications').doc();
            await docRef.set({
                title,
                body,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });
            console.log("Notification saved to Firestore.");
        } catch (error) {
            console.error('Error saving notification:', error);
            
        }
    }
    
}

module.exports = new NotificationController();
