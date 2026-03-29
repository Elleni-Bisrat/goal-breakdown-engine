
import express from "express";

import { protect } from "../middleware/auth.middleware.js";
import {
  getTasksByGoal,
  updateTask,
  deleteTask,
  getTodayTasks,
} from "../controllers/task.controller.js";

const taskRoutes = express.Router();
taskRoutes.use(protect);
taskRoutes.get("/today", getTodayTasks);
taskRoutes.get("/:goalId", getTasksByGoal);
taskRoutes.put("/:id", updateTask);
taskRoutes.delete("/:id", deleteTask);

export default taskRoutes;
