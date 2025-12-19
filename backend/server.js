import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import { connectDB } from "./config/db.js";
import { logger } from "./middleware/logger.js";
import authRoutes from "./routes/authRoutes.js";
import habitRoutes from "./routes/habitRoutes.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

connectDB();

// middleware
app.use(cors());
app.use(express.json());
app.use(logger);

// routes
app.use("/api/auth", authRoutes);
app.use("/api/habits", habitRoutes);

app.get("/", (req, res) => {
  res.send("Smart Habit Tracker backend running!");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});