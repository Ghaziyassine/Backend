import { Router } from "express";

import { login, me } from "../controllers/auth.controller.js";

import { auth } from "../middleware/auth.middleware.js";

import { validate } from "../middleware/validate.middleware.js";

import { loginSchema } from "../schemas/auth.schema.js";

const router = Router();

router.post(
    "/login",
    validate(loginSchema),
    login
);

router.get(
    "/me",
    auth,
    me
);

export default router;