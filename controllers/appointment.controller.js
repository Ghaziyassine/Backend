import prisma from "../config/prisma.js";

export async function getAppointments(req, res) {
    try {
        const appointments = await prisma.appointments.findMany({
            include: {
                patient: true,
                user: true
            }
        });

        res.json(appointments);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

export async function getAppointment(req, res) {
    try {
        const appointment = await prisma.appointments.findUnique({
            where: {
                id: req.params.id
            },
            include: {
                patient: true,
                user: true
            }
        });

        if (!appointment) {
            return res.status(404).json({
                message: "Appointment not found"
            });
        }

        res.json(appointment);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

export async function createAppointment(req, res) {
    try {
        const appointment = await prisma.appointments.create({
            data: req.body
        });

        res.status(201).json(appointment);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

export async function updateAppointment(req, res) {
    try {
        const appointment = await prisma.appointments.update({
            where: {
                id: req.params.id
            },
            data: req.body
        });

        res.json(appointment);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

export async function deleteAppointment(req, res) {
    try {
        await prisma.appointments.delete({
            where: {
                id: req.params.id
            }
        });

        res.json({
            message: "Appointment deleted"
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}