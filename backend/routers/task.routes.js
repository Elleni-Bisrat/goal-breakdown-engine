// import express from "express";

// import {
//   generateTasks,
//   getTasksByGoal,
//   updateTask,
//   deleteTask,
//   updateTaskStatus
// } from "../controllers/taskController.js";

// import { protect } from "../middleware/authMiddleware.js";

// const router = express.Router();

// router.post("/generate/:goalId", protect, generateTasks);

// router.get("/:goalId", protect, getTasksByGoal);

// router.put("/:id", protect, updateTask);

// router.delete("/:id", protect, deleteTask);

// // mark task complete
// router.patch("/:id/status", protect, updateTaskStatus);

// export default router;