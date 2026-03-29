import express from "express";
import { protect } from "../middleware/auth.middleware.js";
import {
  createGoal,
  getGoals,
  getGoalById,
  manualBreakdown,
} from "../controllers/goal.controller.js";
const goalRoutes = express.Router();

goalRoutes.use(protect);

goalRoutes.post("/", createGoal);
goalRoutes.get("/", getGoals);
goalRoutes.get("/:id", getGoalById);
goalRoutes.post("/breakdown", manualBreakdown);

export default goalRoutes;
