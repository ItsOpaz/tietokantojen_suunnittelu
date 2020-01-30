const express = require('express')
const pg = require('pg');
const app = express();

app.get( '/' ,(req, res) => {
  res.sendFile(__dirname+'/views/home.html')
})

app.listen(8000, () =>
  console.log("testi servuu DXD"))
