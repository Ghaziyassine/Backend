
import { Router } from "express";
import { auth } from "../middleware/auth.middleware.js";
import { role } from "../middleware/role.middleware.js";
import {
    getPatients,
    getPatient,
    createPatient,
    updatePatient,
    deletePatient
} from "../controllers/patient.controller.js";

const router = Router();

router.get("/", getPatients);

router.get("/:id", getPatient);

router.post("/", createPatient);

router.put("/:id", updatePatient);

router.delete("/:id", auth,
    role("admin"), deletePatient);

export default router;