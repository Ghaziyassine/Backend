// src/controllers/patient.controller.js

import prisma from "../config/prisma.js";

export async function getPatients(req, res) {
    try {

        const patients = await prisma.patients.findMany();

        res.json(patients);

    } catch (err) {

        res.status(500).json({ error: err.message });

    }
}

export async function getPatient(req, res) {

    try {

        const patient = await prisma.patients.findUnique({
            where: {
                id: req.params.id
            }
        });

        if (!patient) {
            return res.status(404).json({
                message: "Patient not found"
            });
        }

        res.json(patient);

    } catch (err) {

        res.status(500).json({
            error: err.message
        });

    }

}

export async function createPatient(req, res) {

    try {

        const patient = await prisma.patients.create({

            data: req.body

        });

        res.status(201).json(patient);

    } catch (err) {

        res.status(500).json({
            error: err.message
        });

    }

}

export async function updatePatient(req, res) {

    try {

        const patient = await prisma.patients.update({

            where: {
                id: req.params.id
            },

            data: req.body

        });

        res.json(patient);

    } catch (err) {

        res.status(500).json({
            error: err.message
        });

    }

}

export async function deletePatient(req, res) {

    try {

        await prisma.patients.delete({

            where: {
                id: req.params.id
            }

        });

        res.json({
            message: "Patient deleted"
        });

    } catch (err) {

        res.status(500).json({
            error: err.message
        });

    }

}