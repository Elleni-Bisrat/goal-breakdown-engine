import mongoose from 'mongoose'
const taskSchema = new mongoose.Schema(
    {
        title: {
            type: String,
            required: true,
        },
        goal: {
            type: mongoose.Schema.Types.objectId,
            ref: "Goal",
            required: true,
        },
        user: {
            type: mongoose.Schema.Types.objectId,
            ref: "User",
            required: true,
        },
        dueDate: {
            type: Date,
        },
        completed: {
            type: Boolean,
            default: false,
        },
    },
    { timestamps:  true }
)

export const Task = mongoose.model("Task", taskSchema)