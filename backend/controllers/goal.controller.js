import Task from "../models/task.model.js";
import Goal from "../models/goal.model.js";
import {
  generateAIBreakdown,
  generateFallbackBreakdown,
} from "../services/geminiService.js";

const calculateTotalDays = (startDate, endDate) => {
  const start = new Date(startDate);
  const end = new Date(endDate);
  const diffTime = Math.abs(end - start);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  return diffDays;
};

export const createGoal = async (req, res) => {
  try {
    const { title, description, startDate, endDate, priority } = req.body;

    const goal = await Goal.create({
      userId: req.user._id,
      title,
      description,
      startDate,
      endDate,
      priority,
    });

    const totalDays = calculateTotalDays(startDate, endDate);

    let milestones = [];
    let aiGeneratedTasks = [];
    let usedAI = false;

    if (process.env.GEMINI_API_KEY) {
      try {
        console.log("Generating AI breakdown for:", title);
        const aiBreakdown = await generateAIBreakdown(
          title,
          description,
          startDate,
          endDate,
          totalDays,
        );

        milestones = aiBreakdown.milestones;
        aiGeneratedTasks = aiBreakdown.tasks;
        usedAI = true;
        console.log(
          `✅ AI generated ${milestones.length} milestones and ${aiGeneratedTasks.length} tasks`,
        );
      } catch (aiError) {
        console.error("AI generation failed, using fallback:", aiError.message);
        const fallback = generateFallbackBreakdown(
          title,
          startDate,
          endDate,
          totalDays,
        );
        milestones = fallback.milestones;
        aiGeneratedTasks = fallback.tasks;
      }
    } else {
      console.log("⚠️ No GEMINI_API_KEY found, using fallback template");
      const fallback = generateFallbackBreakdown(
        title,
        startDate,
        endDate,
        totalDays,
      );
      milestones = fallback.milestones;
      aiGeneratedTasks = fallback.tasks;
    }

    const startDateTime = new Date(startDate);
    goal.milestones = milestones.map((m, index) => ({
      title: m.title,
      description: m.description || "",
      startDate: new Date(startDateTime),
      endDate: new Date(
        new Date(startDateTime).setDate(
          startDateTime.getDate() + (index + 1) * 7,
        ),
      ),
      completed: false,
    }));

    await goal.save();

    const tasksToSave = aiGeneratedTasks.map((task, index) => {
      const taskDate = new Date(startDateTime);
      taskDate.setDate(startDateTime.getDate() + index);

      return {
        title: task.title,
        description: task.description || `Work on ${title}`,
        dueDate: taskDate,
        goalId: goal._id,
        userId: req.user._id,
        milestoneIndex: task.milestoneIndex || Math.floor(index / 7),
        status: "pending",
      };
    });

    const savedTasks = await Task.insertMany(tasksToSave);

    res.status(201).json({
      goal,
      tasks: savedTasks,
      summary: {
        totalDays: totalDays,
        totalMilestones: milestones.length,
        totalTasks: savedTasks.length,
        generationMethod: usedAI ? "Gemini AI" : "Template Fallback",
      },
    });
  } catch (error) {
    console.error("Create goal error:", error);
    res.status(500).json({
      message: error.message,
    });
  }
};

export const getGoals = async (req, res) => {
  try {
    const goals = await Goal.find({
      userId: req.user._id,
    }).sort({
      createdAt: -1,
    });
    res.json(goals);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getGoalById = async (req, res) => {
  try {
    const goal = await Goal.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });
    if (!goal) {
      return res.status(404).json({ message: "Goal not found" });
    }
    const tasks = await Task.find({
      goalId: goal._id,
      userId: req.user._id,
    }).sort({ dueDate: 1 });
    res.json({ goal, tasks });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const updateGoal = async (req, res) => {
  try {
    const { title, description, startDate, endDate, priority, status } = req.body;
    
    const goal = await Goal.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });
    
    if (!goal) {
      return res.status(404).json({ message: "Goal not found" });
    }
    
    goal.title = title || goal.title;
    goal.description = description !== undefined ? description : goal.description;
    goal.startDate = startDate || goal.startDate;
    goal.endDate = endDate || goal.endDate;
    goal.priority = priority || goal.priority;
    goal.status = status || goal.status;
    
    const updatedGoal = await goal.save();
    
    res.json({
      message: "Goal updated successfully",
      goal: updatedGoal
    });
  } catch (error) {
    console.error("Update goal error:", error);
    res.status(500).json({ message: error.message });
  }
};

export const deleteGoal = async (req, res) => {
  try {
    const goal = await Goal.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id,
    });
    
    if (!goal) {
      return res.status(404).json({ message: "Goal not found" });
    }
    
    const deletedTasks = await Task.deleteMany({ goalId: req.params.id });
    
    res.json({
      message: "Goal deleted successfully",
      deletedGoal: {
        id: goal._id,
        title: goal.title
      },
      tasksDeleted: deletedTasks.deletedCount
    });
  } catch (error) {
    console.error("Delete goal error:", error);
    res.status(500).json({ message: error.message });
  }
};

export const manualBreakdown = async (req, res) => {
  try {
    const { title, description, startDate, endDate } = req.body;
    const totalDays = calculateTotalDays(startDate, endDate);

    let result;
    if (process.env.GEMINI_API_KEY) {
      result = await generateAIBreakdown(
        title,
        description,
        startDate,
        endDate,
        totalDays,
      );
    } else {
      result = generateFallbackBreakdown(title, startDate, endDate, totalDays);
    }

    res.json({
      ...result,
      totalDays,
      preview: true,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
