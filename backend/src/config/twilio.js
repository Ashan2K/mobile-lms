require("dotenv").config();
require("twilio");

const twilioConfig = {
  authToken: process.env.TWILIO_AUTH_TOKEN,
  serviceSid: process.env.TWILIO_SERVICE_SID,
  phoneNumber: process.env.TWILIO_PHONE_NUMBER
}

