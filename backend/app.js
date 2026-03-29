import express from "express";
import cors from "cors";
import authRoutes from "./routes/authRoutes.js";
import goalRoutes from "./routes/goalRoutes.js";
import taskRoutes from "./routes/taskRoutes.js";
import progressRoutes from "./routes/progressRoutes.js";
const app = express();
app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);

app.use("/api/goals", goalRoutes);

app.use("/api/tasks", taskRoutes);

app.use("/api/progress", progressRoutes);

app.get("/", (req, res) => {
  res.send("Goal Breakdown API running...");
});

export default app;