import { Router } from "express";
import {
    getAuditLogs,
    getAuditLog
} from "../controllers/audit.controller.js";

const router = Router();

router.get("/", getAuditLogs);

router.get("/:id", getAuditLog);

export default router;