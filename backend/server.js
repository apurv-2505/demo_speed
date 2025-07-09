const express = require("express");
const cors = require("cors");
const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

let store = [];
let currentId = 1;

app.post("/data", (req, res) => {
  const { data } = req.body;
  if (!data) return res.status(400).json({ error: "Missing data field" });

  const newItem = {
    id: currentId++,
    data,
    timestamp: new Date().toISOString(),
  };
  store.push(newItem);

  res.status(201).json(newItem);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
  console.log(`Health check: http://localhost:${port}/health`);
});
