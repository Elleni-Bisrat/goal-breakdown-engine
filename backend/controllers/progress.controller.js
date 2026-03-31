import Task from "../models/task.model.js";
export const getGoalProgress = async (req, res) => {
  try {
    const { goalId } = req.params;

    const totalTasks = await Task.countDocuments({
      goalId,
      userId: req.user._id,
    });

    const completedTasks = await Task.countDocuments({
      goalId,
      userId: req.user._id,
      status: "completed",
    });

    const progress =
      totalTasks === 0
        ? 0
        : Math.round((completedTasks / totalTasks) * 100);

    res.json({
      totalTasks,
      completedTasks,
      progress,
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};
export const getDashboardProgress = async (req, res) => {
  try {
    const totalTasks = await Task.countDocuments({
      userId: req.user._id,
    });

    const completedTasks = await Task.countDocuments({
      userId: req.user._id,
      status: "completed",
    });

    const progress =
      totalTasks === 0
        ? 0
        : Math.round((completedTasks / totalTasks) * 100);

    res.json({
      totalTasks,
      completedTasks,
      progress,
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};