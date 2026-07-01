import prisma from "../config/prisma.js";

export async function getUsers(req, res) {
    try {
        const users = await prisma.users.findMany();

        res.json(users);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

export async function getUser(req, res) {
    try {
        const user = await prisma.users.findUnique({
            where: {
                id: req.params.id
            }
        });

        if (!user) {
            return res.status(404).json({
                message: "User not found"
            });
        }

        res.json(user);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

export async function createUser(req, res) {
    try {
        const user = await prisma.users.create({
            data: req.body
        });

        res.status(201).json(user);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

export async function updateUser(req, res) {
    try {
        const user = await prisma.users.update({
            where: {
                id: req.params.id
            },
            data: req.body
        });

        res.json(user);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

export async function deleteUser(req, res) {
    try {
        await prisma.users.delete({
            where: {
                id: req.params.id
            }
        });

        res.json({
            message: "User deleted"
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}