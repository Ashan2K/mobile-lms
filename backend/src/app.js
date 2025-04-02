const express = require('express');
const cookieParser = require('cookie-parser');
require("dotenv").config();
const PORT = process.env.PORT || 8080;

const app = express();

app.use(express.json())
app.use(cookieParser())

const router = require("./routes");
app.use(router);


app.listen(PORT,'0.0.0.0', () => {
    console.log(`Listening on port ${PORT}`,);
});
