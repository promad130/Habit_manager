import express from "express";
import Habit from "../models/Habit.js";
import HabitLog from "../models/Log.js";
import { validateHabitFields } from "../middleware/validateHabit.js";
import { ownerCheck } from "../middleware/ownerCheck.js";

const router = express.Router();

/**
 * POST /api/habits
 * Body: { title, description?, frequency, owner (userId) }
 */
router.post("/", validateHabitFields, async (req, res) => {
  try {
    const { title, description, frequency, owner } = req.body;

    const habit = await Habit.create({
      title,
      description,
      frequency,
      owner,
    });

    return res.status(201).json(habit);
  } catch (err) {
    console.error("Create habit error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

/**
 * GET /api/habits/:userId?status=active|archived
 */
router.get("/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const { status } = req.query;

    const filter = { owner: userId };
    if (status) {
      filter.status = status;
    }

    const habits = await Habit.find(filter).sort({ createdAt: -1 });

    return res.json(habits);
  } catch (err) {
    console.error("Get habits error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

/**
 * PUT /api/habits/:habitId
 * Body: { userId, ...fieldsToUpdate }
 */
router.put("/:habitId", ownerCheck, async (req, res) => {
  try {
    const updates = req.body;
    delete updates.userId; // userId used only for ownerCheck

    const updated = await Habit.findByIdAndUpdate(
      req.params.habitId,
      updates,
      { new: true }
    );

    return res.json(updated);
  } catch (err) {
    console.error("Update habit error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

/**
 * DELETE /api/habits/:habitId
 * Body: { userId }
 */
router.delete("/:habitId", ownerCheck, async (req, res) => {
  try {
    await Habit.findByIdAndDelete(req.params.habitId);
    return res.json({ message: "Habit deleted" });
  } catch (err) {
    console.error("Delete habit error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

/**
 * POST /api/habits/:habitId/mark
 * Body: { date, completed?, userId }
 */
router.post("/:habitId/mark", ownerCheck, async (req, res) => {
  try {
    const { date, completed = true } = req.body;
    const habitId = req.params.habitId;

    if (!date) {
      return res.status(400).json({ message: "date is required (YYYY-MM-DD)" });
    }

    const log = await HabitLog.findOneAndUpdate(
      { habitId, date },
      { completed },
      { new: true, upsert: true }
    );

    return res.json(log);
  } catch (err) {
    console.error("Mark habit error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

/**
 * GET /api/habits/:habitId/logs
 */
router.get("/:habitId/logs", async (req, res) => {
  try {
    const logs = await HabitLog.find({ habitId: req.params.habitId }).sort({
      date: 1,
    });

    return res.json(logs);
  } catch (err) {
    console.error("Get logs error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

/**
 * GET /api/habits/:habitId/stats
 */
router.get("/:habitId/stats", async (req, res) => {
  try {
    const logs = await HabitLog.find({ habitId: req.params.habitId });

    const totalDaysTracked = logs.length;
    const daysCompleted = logs.filter((log) => log.completed).length;

    const completionRate =
      totalDaysTracked === 0
        ? 0
        : Math.round((daysCompleted / totalDaysTracked) * 100);

    return res.json({
      totalDaysTracked,
      daysCompleted,
      completionRate,
    });
  } catch (err) {
    console.error("Get stats error:", err);
    return res.status(500).json({ message: "Server error" });
  }
});

export default router;