import Habit from "../models/Habit.js";

export const ownerCheck = async (req, res, next) => {
  try {
    const { userId } = req.body;
    const habitId = req.params.habitId || req.params.id;

    if (!userId) {
      return res.status(400).json({ message: "userId is required" });
    }

    const habit = await Habit.findById(habitId);

    if (!habit) {
      return res.status(404).json({ message: "Habit not found" });
    }

    if (habit.owner.toString() !== userId) {
      return res.status(403).json({ message: "Forbidden: not habit owner" });
    }

    // attach habit so route doesn't need to load again if it doesn't want to
    req.habit = habit;

    next();
  } catch (err) {
    console.error("Owner check error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};