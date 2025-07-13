require("dotenv").config();
const express = require('express');


const Stripe = require('stripe');

class PaymentController {
    constructor() {
        this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY); // Replace with your actual Stripe secret key
    }

    async createPaymentIntent(req, res) {
    try {
        const { amount, courseId, userId } = req.body; // Use userId for consistency

        if (!amount || !courseId || !userId) {
            return res.status(400).send('Amount, Course ID, and User ID are required');
        }

        const paymentIntent = await this.stripe.paymentIntents.create({
            amount, // should be integer, e.g., 2000 for $20.00
            currency: 'usd', // Use a supported currency
            metadata: {
                courseId: courseId,
                userId: userId
            }
        });

        res.status(200).json({ clientSecret: paymentIntent.client_secret });
    } catch (error) {
        console.error('Error creating payment intent: ', error);
        res.status(500).send('Error creating payment intent');
    }
}
    async payMonthlyFee(req, res) {
        try {
            const { courseId, userId, amount } = req.body; // Extract courseId, userId, and amount from the request body

            if (!courseId || !userId || !amount) {
                return res.status(400).send('Course ID, User ID, and Amount are required');
            }

            const paymentIntent = await this.stripe.paymentIntents.create({
                amount: amount * 100, // Convert to cents
                currency: 'usd', // Use a supported currency
                metadata: {
                    courseId: courseId,
                    userId: userId
                }
            });

            res.status(200).json({ clientSecret: paymentIntent.client_secret });
        } catch (error) {
            console.error('Error processing monthly fee payment: ', error);
            res.status(500).send('Error processing monthly fee payment');
        }
    }

}

module.exports = new PaymentController();