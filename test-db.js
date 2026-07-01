import fs from "fs/promises";
import bcrypt from "bcrypt";

const FILE_PATH = "./clinicflow.sql"; // Change to your SQL file path
const PASSWORD = "password123";
const SALT_ROUNDS = 10;

async function updateHashes() {
    try {
        let sql = await fs.readFile(FILE_PATH, "utf8");

        // Generate one hash (same password for all seeded users)
        const hash = await bcrypt.hash(PASSWORD, SALT_ROUNDS);

        // Replace every bcrypt hash in the SQL file
        sql = sql.replace(
            /\$2[aby]\$\d{2}\$[./A-Za-z0-9]{53}/g,
            hash
        );

        await fs.writeFile(FILE_PATH, sql);

        console.log("✅ Password hashes updated successfully.");
        console.log(`Password for all users is: ${PASSWORD}`);
        console.log(`Generated hash: ${hash}`);

    } catch (err) {
        console.error(err);
    }
}

updateHashes();