
import Task from "../models/task.model.js";
import Goal from "../models/goal.model.js";

export const getGoalProgress = async (req, res) => {
  try {
    const goal = await Goal.findOne({ 
      _id: req.params.goalId, 
      userId: req.user._id 
    });
    
    if (!goal) {
      return res.status(404).json({ message: "Goal not found" });
    }
    
    const tasks = await Task.find({ 
      goalId: goal._id, 
      userId: req.user._id 
    });
    
    const totalTasks = tasks.length;
    const completedTasks = tasks.filter(t => t.status === "completed").length;
    const completionPercentage = totalTasks > 0 
      ? Math.round((completedTasks / totalTasks) * 100) 
      : 0;
    
    const milestoneProgress = goal.milestones.map((milestone, index) => {
      const milestoneTasks = tasks.filter(t => t.milestoneIndex === index);
      const milestoneCompleted = milestoneTasks.filter(t => t.status === "completed").length;
      const milestoneTotal = milestoneTasks.length;
      return {
        title: milestone.title,
        completed: milestoneCompleted,
        total: milestoneTotal,
        percentage: milestoneTotal > 0 ? Math.round((milestoneCompleted / milestoneTotal) * 100) : 0
      };
    });
    
    res.json({
      goalId: goal._id,
      goalTitle: goal.title,
      totalTasks,
      completedTasks,
      pendingTasks: totalTasks - completedTasks,
      completionPercentage,
      milestoneProgress,
      startDate: goal.startDate,
      endDate: goal.endDate,
      daysRemaining: Math.ceil((new Date(goal.endDate) - new Date()) / (1000 * 60 * 60 * 24))
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getDashboardProgress = async (req, res) => {
  try {
    const goals = await Goal.find({ 
      userId: req.user._id,
      status: "active"
    });
    
    const allTasks = await Task.find({ userId: req.user._id });
    const completedTasks = allTasks.filter(t => t.status === "completed").length;
    
    const goalsProgress = await Promise.all(
      goals.map(async (goal) => {
        const tasks = await Task.find({ goalId: goal._id, userId: req.user._id });
        const completed = tasks.filter(t => t.status === "completed").length;
        return {
          goalId: goal._id,
          title: goal.title,
          totalTasks: tasks.length,
          completedTasks: completed,
          percentage: tasks.length > 0 ? Math.round((completed / tasks.length) * 100) : 0
        };
      })
    );

    res.json({
      totalGoals: goals.length,
      totalTasks: allTasks.length,
      completedTasks,
      overallProductivity: allTasks.length > 0 
        ? Math.round((completedTasks / allTasks.length) * 100) 
        : 0,
      goalsProgress
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};