
import Task from "../models/task.model.js";
import Goal from "../models/goal.model.js";

export const getTasksByGoal = async (req, res) => {
  try {
    const tasks = await Task.find({
      goalId: req.params.goalId,

      userId: req.user._id,
    }).sort({
      dueDate: 1,
    });

    res.json(tasks);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

export const updateTask = async (req, res) => {
  try {
    const { title, description, dueDate, status } = req.body;

    const task = await Task.findOne({
      _id: req.params.id,

      userId: req.user._id,
    });

    if (!task) {
      return res.status(404).json({
        message: "Task not found",
      });
    }

    task.title = title || task.title;

    task.description = description || task.description;

    task.dueDate = dueDate || task.dueDate;

    task.status = status || task.status;

    const updatedTask = await task.save();

    res.json(updatedTask);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

export const deleteTask = async (req, res) => {
  try {
    const task = await Task.findOneAndDelete({
      _id: req.params.id,

      userId: req.user._id,
    });

    if (!task) {
      return res.status(404).json({
        message: "Task not found",
      });
    }

    res.json({
      message: "Task deleted successfully",
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

export const getTodayTasks = async (req, res) => {
  try {
    const today = new Date();

    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    const tasks = await Task.find({
      userId: req.user._id,

      dueDate: {
        $gte: today,

        $lt: tomorrow,
      },

      status: "pending",
    }).populate("goalId", "title");

    res.json(tasks);
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};
