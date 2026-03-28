import express from 'express'
const taskRouter = express.Router()

import {
    getTasksByGoal,
    deleteTask,
    toggleTaskStatus,
    updateTask
} from '../controllers/taskController.js'

import validationMiddleware from '../middleware/validationMiddleware.js'

taskRouter.get("/:goalId", validationMiddleware, getTasksByGoal)

taskRouter.put("/:id", validationMiddleware, updateTask)

taskRouter.delete("/:id", validationMiddleware, deleteTask)

taskRouter.patch("/:id/status", validationMiddleware, toggleTaskStatus)

export default taskRouter