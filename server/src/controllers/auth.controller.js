const bcrypt = require("bcryptjs");
const { prisma } = require("../lib/prisma");
const { USER_ROLES } = require("../constants/enums");
const { signToken } = require("../utils/jwt");
const { serialize } = require("../utils/serialize");
const { ApiError } = require("../utils/api-error");

const authUserSelect = {
  id: true,
  name: true,
  email: true,
  role: true,
  createdAt: true,
  updatedAt: true,
  vendor: {
    select: {
      id: true,
    },
  },
};

const register = async (req, res) => {
  const { name, email, password, role } = req.body;

  const existingUser = await prisma.user.findUnique({
    where: { email },
  });

  if (existingUser) {
    throw new ApiError(409, "Email is already in use");
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await prisma.$transaction(async (tx) => {
    const createdUser = await tx.user.create({
      data: {
        name,
        email,
        passwordHash,
        role,
        vendor:
          role === USER_ROLES.VENDOR
            ? {
                create: {},
              }
            : undefined,
      },
      select: authUserSelect,
    });

    return createdUser;
  });

  const token = signToken(user);

  res.status(201).json({
    token,
    user: serialize(user),
  });
};

const login = async (req, res) => {
  const { email, password } = req.body;

  const user = await prisma.user.findUnique({
    where: { email },
    include: {
      vendor: {
        select: { id: true },
      },
    },
  });

  if (!user) {
    throw new ApiError(401, "Invalid email or password");
  }

  const passwordMatches = await bcrypt.compare(password, user.passwordHash);

  if (!passwordMatches) {
    throw new ApiError(401, "Invalid email or password");
  }

  const token = signToken(user);

  res.json({
    token,
    user: serialize({
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      vendor: user.vendor,
    }),
  });
};

const me = async (req, res) => {
  res.json({
    user: serialize({
      id: req.auth.user.id,
      name: req.auth.user.name,
      email: req.auth.user.email,
      role: req.auth.user.role,
      createdAt: req.auth.user.createdAt,
      updatedAt: req.auth.user.updatedAt,
      vendor: req.auth.user.vendor,
    }),
  });
};

module.exports = { register, login, me };
