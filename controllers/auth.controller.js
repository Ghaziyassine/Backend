import prisma from "../config/prisma.js";
import bcrypt from "bcrypt";
import { generateToken } from "../utils/jwt.js";

export async function login(req, res) {

    const { email, password } = req.body;

    const user = await prisma.users.findUnique({
        where: {
            email
        }
    });

    if (!user) {
        return res.status(401).json({
            message: "Invalid credentials"
        });
    }

    const valid = await bcrypt.compare(
        password,
        user.password_hash
    );

    if (!valid) {
        return res.status(401).json({
            message: "Invalid credentials"
        });
    }

    const token = generateToken(user);

    res.json({
        token
    });

}

export async function me(req, res) {

    const user = await prisma.users.findUnique({

        where: {
            id: req.user.id
        },

        select: {
            id: true,
            full_name: true,
            email: true,
            role: true
        }

    });

    res.json(user);

}