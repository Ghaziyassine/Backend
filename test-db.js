import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function testConnection() {
  try {
    await prisma.$connect();
    console.log("Connected to the database!");

    // Optional: execute a simple query
    const result = await prisma.$queryRaw`SELECT NOW()`;

    console.log("Database time:", result);
  } catch (error) {
    console.error("❌ Connection failed");
    console.error(error);
  } finally {
    await prisma.$disconnect();
  }
}

testConnection();