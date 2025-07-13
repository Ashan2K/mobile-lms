const express = require('express');
const admin = require('firebase-admin');

const db = admin.firestore();

class MockExamController {
    async createQuestionsBank(req, res) {
        const { questions, title } = req.body; 
        
        
        if (questions.length !== 20) {
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

    async createAudioQuestionsBank(req, res) {
        const { questions, title,type } = req.body; 
        
        
        if (questions.length !== 20) {
            return res.status(400).json({ error: "You must provide exactly 30 questions." });
        }

        try {
            
            const newQuestionsBank = {
                questions: questions,
                title:title, 
                type:type,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            
            const docRef = await db.collection('audioQuestionsBank').add(newQuestionsBank);

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
    async getAudioQuestionsBank(req, res) {
        try {
            const snapshot = await db.collection('audioQuestionsBank').get();
            const questionsBanks = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            res.status(200).json(questionsBanks);
        } catch (e) {
            console.error('Error fetching audio questions bank:', e);
            res.status(500).json({ error: 'Failed to fetch audio questions bank' });
        }
    }

    async createMockExam(req, res) {
        const { title, description, bankId, audioBankId, visibility} = req.body;

        if (!title || !bankId || !audioBankId || !visibility) {
            return res.status(400).json({ error: "All fields are required." });
        }

        try {
            const newMockExam = {
                title,
                description,
                bankId,
                audioBankId,
                visibility,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            const docRef = await db.collection('mockExams').add(newMockExam);

            res.status(200).json({ message: 'Mock exam created successfully', id: docRef.id });

        } catch (e) {
            console.error('Error creating mock exam:', e);
            res.status(500).json({ error: 'Failed to create mock exam' });
        }
    }

    async getMockExams(req, res) {
        try {
            const snapshot = await db.collection('mockExams').get();
            const mockExams = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            res.status(200).json(mockExams);
        } catch (e) {
            console.error('Error fetching mock exams:', e);
            res.status(500).json({ error: 'Failed to fetch mock exams' });
        }
    }

    async getMcqBankbyId(req, res) {
        const { id } = req.params;
        console.log("ID:", id);
        if (!id) {
            return res.status(400).json({ error: "ID is required." });
        }

        try {
            const doc = await db.collection('questionsBank').doc(id).get();

            if (!doc.exists) {
                return res.status(404).json({ error: "Questions bank not found." });
            }

            res.status(200).json({ id: doc.id, ...doc.data() });

        } catch (e) {
            console.error('Error fetching questions bank by ID:', e);
            res.status(500).json({ error: 'Failed to fetch questions bank' });
        }
    }

    async getAudioBankbyId(req, res) {
        const { id } = req.params;

        if (!id) {
            return res.status(400).json({ error: "ID is required." });
        }


        try {
            const doc = await db.collection('audioQuestionsBank').doc(id).get();

            if (!doc.exists) {
                return res.status(404).json({ error: "Audio questions bank not found." });
            }

            res.status(200).json({ id: doc.id, ...doc.data() });

        } catch (e) {
            console.error('Error fetching audio questions bank by ID:', e);
            res.status(500).json({ error: 'Failed to fetch audio questions bank' });
        }
    }
}

module.exports = new MockExamController();
