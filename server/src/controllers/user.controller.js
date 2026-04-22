const bcrypt = require("bcryptjs");
const { prisma } = require("../lib/prisma");
const { ApiError } = require("../utils/api-error");

const changePassword = async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  const user = await prisma.user.findUnique({
    where: { id: req.auth.userId },
  });

  const matches = await bcrypt.compare(currentPassword, user.passwordHash);

  if (!matches) {
    throw new ApiError(400, "Current password is incorrect");
  }

  const samePassword = await bcrypt.compare(newPassword, user.passwordHash);

  if (samePassword) {
    throw new ApiError(400, "New password must be different from current password");
  }

  const passwordHash = await bcrypt.hash(newPassword, 10);

  await prisma.user.update({
    where: { id: req.auth.userId },
    data: { passwordHash },
  });

  res.json({ message: "Password updated successfully" });
};

module.exports = { changePassword };
