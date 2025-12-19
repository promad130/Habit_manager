import mongoose from "mongoose";

const habitSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      default: "",
    },
    frequency: {
      type: String,
      enum: ["daily", "weekly"],
      required: true,
    },
    status: {
      type: String,
      enum: ["active", "archived"],
      default: "active",
    },
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  { timestamps: true }
);

export default mongoose.model("Habit", habitSchema);