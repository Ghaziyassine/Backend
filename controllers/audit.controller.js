import prisma from "../config/prisma.js";

export async function getAuditLogs(req, res) {
    try {
        const logs = await prisma.audit_log.findMany({
            orderBy: {
                created_at: "desc"
            }
        });

        res.json(logs);
    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
}

export async function getAuditLog(req, res) {
    try {
        const log = await prisma.audit_log.findUnique({
            where: {
                id: req.params.id
            }
        });

        if (!log) {
            return res.status(404).json({
                message: "Audit log not found"
            });
        }

        res.json(log);
    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
}