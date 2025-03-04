const express = require('express');
const cookieParser = require('cookie-parser');
require("dotenv").config();
const PORT = process.env.PORT || 8080;

const app = express();

app.use(express.json())
app.use(cookieParser())

app.get('/', (req, res) => {
    res.send('Hello World');
});


const router = require("./routes");
app.use(router);


app.listen(PORT, () => {
    console.log(`Listening on port ${PORT}`);
});
