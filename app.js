import express from "express";

import patientRoutes from "./routes/patient.routes.js";
// import appointmentRoutes from "./routes/appointment.routes.js";
// import userRoutes from "./routes/user.routes.js";

const app = express();

app.use(express.json());

app.use("/patients", patientRoutes);
// app.use("/appointments", appointmentRoutes);
// app.use("/users", userRoutes);

export default app;