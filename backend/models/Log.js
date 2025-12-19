import mongoose from "mongoose";

const habitLogSchema = new mongoose.Schema(
  {
    habitId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Habit",
      required: true,
    },
    date: {
      type: String, // "YYYY-MM-DD"
      required: true,
    },
    completed: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

export default mongoose.model("HabitLog", habitLogSchema);