//
// node.js example for Tietokantojen suunnittelu
//
// Install required packages (see package.json) by running: npm install
//
// Edit connectionString in util.js with your postgresql information: 
// var connectionString = "postgres://user:pass@localhost:port/dbname";
//
// Start node server: node lasse_esim.js
// Quick test in linux-desktop.cc.tut.fi on command line by typing: curl tkannatX.cs.tut.fi:8888
//
// Note! 
// - To execute any changes on the source code, you must restart the node server. 
// - Pug files can be modified without restart.
// - Any unhandled error will crash the server.
//
// This example works with a db populated like this:
// CREATE TABLE esimerkki (eka INTEGER, toka INTEGER);
// INSERT INTO esimerkki VALUES (1, 2);
// INSERT INTO esimerkki VALUES (3, 4);
const defaultQuery = "SELECT * FROM esimerkki";
const dropDownQuery = "SELECT eka from esimerkki";

var util = require('./util');
var express = require('express');
var app = express();
var bodyParser = require('body-parser');
app.use(bodyParser.urlencoded({ extended: false }));

app.set('views', './views');
app.set('view engine', 'pug');


// route - HTTP GET to http://tkannatX.cs.tut.fi:8888/    
app.get('/', function (req, res) {
    
    // resultCollector collects the contents that will be rendered on the WWW page.
    var resultCollector = {};

    // first run query for drop down menu
    util.runDbQuery(dropDownQuery, buildDropdown, res, resultCollector, defaultQuery);

});

// buildDropdown - add some dropdown menu items and continue with a query written on the textfield.
// Parameters:
// query: the query to continue with
// dbResult: results of database query, these are added to dropdown menu
// res: HTTP response
// err: database error message 
// resultCollector: collecting content to be rendered
function buildDropdown(query, dbResult, res, err, resultCollector, postQuery) {

    if(dbResult && 'rows' in dbResult) {
        resultCollector.dropdown = dbResult.rows;
    }
    // continue with a query written on the textfield.
    util.runDbQuery(postQuery, buildHtml, res, resultCollector);

}

// buildHtml - create HTML form and show SQL query results in HTML table.
// Parameters:
// query: text query to the form from HTTP POST
// dbResult: result of database query
// res: HTTP response
// err: database error message
// resultCollector: collecting content to be rendered 
function buildHtml(query, dbResult, res, err, resultCollector) {
    resultCollector.result = dbResult;

    resultCollector.title = 'Liiga-Lasse';
    resultCollector.message = 'Liiga-Lasse';
    resultCollector.query = query;
    resultCollector.error = err;

    //send the content to a view named 'frontpage' 
    res.render('frontpage', resultCollector);
}

// route - HTTP GET to http://tkannatX.cs.tut.fi:8888/toinensivu    
app.get('/toinensivu', function (req, res) {

    // rendering without resultCollector
    res.render('toinensivu', { 
        title: 'Toinen sivu', 
        message: 'Toisen sivun teksti'
    });
});

// route - HTTP POST to http://tkannatX.cs.tut.fi:8888/dropdown    
app.post('/dropdown', function (req, res) {

    var resultCollector = {};

    if(req.body.drop == "drop" || req.body.drop == "down" || req.body.drop == "menu") {
        util.runDbQuery("SELECT NOW() --This is an example: " + req.body.drop, 
            buildHtml, res, resultCollector, req.body.query);
    }
    else {
        // This is a bad example! 
        // Catenating user input with database queries can lead to SQL injection!
        // Using parameterized queries is recommended instead.
        util.runDbQuery("SELECT eka FROM esimerkki WHERE eka = " + req.body.drop,
            buildHtml, res, resultCollector, req.body.query);
    }    
});


app.post('/date', function (req, res) {

    var resultCollector = {};
    util.runDbQuery("SELECT NOW() --Example: " + req.body.date, buildHtml, res, resultCollector, req.body.query);

});


// route - HTTP POST to http://tkannatX.cs.tut.fi:8888/    
app.post('/', function (req, res) {

    var resultCollector = {};

    // Use builDropdown function as a callback function
    // because it needs to be executed after the db query.   
    util.runDbQuery(dropDownQuery, buildDropdown, res, resultCollector, req.body.query);    
});





// Binds and listens for connections on the specified port.
app.listen(8888, function () {
    console.log('Example app listening on port 8888');
});
