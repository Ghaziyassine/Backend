import express from "express";
const app = express();
const PORT = 3000;
app.use(express.json());

let users = [
    {"id": 1, "name": "John Doe"},
    {"id": 2, "name": "Jane Smith"}
];

//get all users
app.get("/users", (req, res) => {
    res.json(users);
});

app.get("/users/:id", (req, res) => {   
  res.json(users.find(user => user.id === parseInt(req.params.id)) || { error: "User not found" });
});

app.post("/users", (req, res) => {
    const newUser = { id: users.length + 1, name: req.body.name };
    users.push(newUser);
    res.status(201).json(newUser);
});

app.put("/users/:id", (req, res) => {
    const user = users.find(user => user.id === parseInt(req.params.id));
    if (!user) {
        return res.status(404).json({ error: "User not found" });
    }
    user.name = req.body.name;
    res.json(user);
});
app.delete("/users/:id", (req, res) => {
    const userIndex = users.findIndex(user => user.id === parseInt(req.params.id));
    if (userIndex === -1) {
        return res.status(404).json({ error: "User not found" });
    }
    users.splice(userIndex, 1);
    res.json({ message: "User deleted" });
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});