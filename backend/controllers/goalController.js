import Goal from "../models/Goal.js";

// CREATE
export const createGoal = async (req, res) => {
  try {
    const { title, description, duration } = req.body;

    if (!title || !duration) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const goal = await Goal.create({
      title,
      description,
      duration,
      user: req.user.id,
    });

    res.status(201).json(goal);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET ALL
export const getGoals = async (req, res) => {
  const goals = await Goal.find({ user: req.user.id });
  res.json(goals);
};

// GET ONE
export const getGoalById = async (req, res) => {
  const goal = await Goal.findById(req.params.id);

  if (!goal) return res.status(404).json({ message: "Not found" });

  res.json(goal);
};

// UPDATE
export const updateGoal = async (req, res) => {
  const updated = await Goal.findByIdAndUpdate(req.params.id, req.body, {
    new: true,
  });

  res.json(updated);
};

// DELETE
export const deleteGoal = async (req, res) => {
  await Goal.findByIdAndDelete(req.params.id);
  res.json({ message: "Deleted" });
};