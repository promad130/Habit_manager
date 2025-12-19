export const validateHabitFields = (req, res, next) => {
  const { title, owner, frequency } = req.body;

  if (!title || !owner || !frequency) {
    return res.status(400).json({
      message: "Missing required fields: title, owner, frequency",
    });
  }

  next();
};