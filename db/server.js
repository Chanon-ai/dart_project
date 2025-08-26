const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcrypt');
const con = require('./db');
const app = express();


app.use(express.json());
app.use(express.urlencoded({ extended: true }));


// ---------------- Register ----------------
app.post('/register', (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) return res.status(400).json({ message: "Username and password required" });


    const sqlCheck = "SELECT * FROM users WHERE username = ?";
    con.query(sqlCheck, [username], async (err, results) => {
        if (err) return res.status(500).json({ message: "Database error" });
        if (results.length > 0) return res.status(400).json({ message: "Username already exists" });


        const hashedPassword = await bcrypt.hash(password, 10);


        const sqlInsert = "INSERT INTO users (username, password) VALUES (?, ?)";
        con.query(sqlInsert, [username, hashedPassword], (err2, result2) => {
            if (err2) return res.status(500).json({ message: "Database error" });
            res.status(201).json({ message: "Register success", user: username });
        });
    });
});


// ---------------- Login ----------------
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    const sql = "SELECT id, password FROM users WHERE username = ?";
    con.query(sql, [username], (err, results) => {
        if (err) return res.status(500).send("Database error");
        if (results.length !== 1) return res.status(401).send("Wrong username");


        const user = results[0];
        bcrypt.compare(password, user.password, (err, same) => {
            if (err) return res.status(500).send("Hashing error");
            if (!same) return res.status(401).send("Wrong password");
            res.status(200).json({ userId: user.id });
        });
    });
});


// ---------------- Get Expenses ----------------
app.get('/expense/:userId', (req, res) => {
    const userId = req.params.userId;
    const sql = "SELECT * FROM expense WHERE user_id = ?";
    con.query(sql, [userId], (err, results) => {
        if (err) return res.status(500).send("Server error");
        res.json(results);
    });
});

// ---------------- Search Expense ----------------


// ---------------- Add new Expense ----------------


// ---------------- Delete an Expense ----------------





const PORT = 3000;
app.listen(PORT, () => {
    console.log('Server is running at ' + PORT);
});
