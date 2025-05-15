const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();

class MockExamController {
    async createQuestionsBank(req, res) {
        const { questions, title } = req.body; 
        
        
        if (questions.length !== 3) {
            return res.status(400).json({ error: "You must provide exactly 30 questions." });
        }

        try {
            
            const newQuestionsBank = {
                questions: questions,
                title:title, 
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            
            const docRef = await db.collection('questionsBank').add(newQuestionsBank);

            res.status(200).json({ message: 'Questions bank created successfully', id: docRef.id });

        } catch (e) {
            console.error('Error creating questions bank:', e);
            res.status(500).json({ error: 'Failed to create questions bank' });
        }
    }

    async getQuestionsBank(req, res) {
        try {
            const snapshot = await db.collection('questionsBank').get();
            const questionsBanks = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            res.status(200).json(questionsBanks);
        } catch (e) {
            console.error('Error fetching questions bank:', e);
            res.status(500).json({ error: 'Failed to fetch questions bank' });
        }
    }
}

module.exports = new MockExamController();
