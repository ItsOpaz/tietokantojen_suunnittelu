
const { Client } = require('pg')

const client = Client({
    connectionString: "postgresql://sqlmanager:keittovesa@localhost:5432/iflac"
})

// Tänne kyselyt sun muut backarikoodit
