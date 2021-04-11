require('dotenv').config();
var mongoose = require('mongoose');

const express = require("express");
const app = express();

const port   = process.env.SERVER_PORT || 3001;


const dbHost = process.env.DB_HOST || "localhost";
const dbPort = process.env.DB_PORT || 27017;
const dbName = process.env.DB_NAME || "aos";


var mongoAdress = 'mongodb://'+dbHost+':'+dbPort+"/"+dbName


mongoose.connect(mongoAdress).catch(error => {
  console.log(`Cannot connect to db error: ${error}`)
  process.exit(1)
});;

var Message = mongoose.model("message", mongoose.Schema(
  {
      message : {
          type : String,
      }
  }
));

let version = require('fs').readFileSync('./version', 'utf8');

app.get('/', async (req, res) => {
  let message = await Message.findOne();
  if (!message) {
    message = new Message();
    message.message = "Hello world!";
    message = await message.save();
  }
  res.send(`${message.message}<br/>this version: ${version}`)
})
app.listen(port, function() {
  console.log("Server is running on Port: " + port);
});