import express from "express";

import patientRoutes from "./routes/patients.routes.js";
import appointmentRoutes from "./routes/appointments.routes.js";
import userRoutes from "./routes/users.routes.js";
import auditRoutes from "./routes/audit.routes.js";
import authRoutes from "./routes/auth.routes.js";

const app = express();
app.use(express.json());
app.use("/api/auth", authRoutes);

app.use("/patients", patientRoutes);
app.use("/appointments", appointmentRoutes);
app.use("/users", userRoutes);
app.use("/audit", auditRoutes);



// router.delete("/:id", auth, role("admin"), deleteUser);



export default app;