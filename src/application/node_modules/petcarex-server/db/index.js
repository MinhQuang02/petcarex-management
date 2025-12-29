import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import dotenv from "dotenv";

dotenv.config();

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
    throw new Error("DATABASE_URL is not defined");
}

console.log('Initializing database connection...');

// Use the connection string as provided in environment variables
const realConnectionString = connectionString;

// Mask the password for logging
const maskedString = realConnectionString.replace(/:([^@]+)@/, ':****@');
console.log(`DATABASE_URL (Used): ${maskedString}`);

const client = postgres(realConnectionString, {
    prepare: false, // Keep false for compatibility
    ssl: { rejectUnauthorized: false }, // Allow self-signed certs or loose validation
    connect_timeout: 30, // Increase timeout to 30s
    keep_alive: 20,
    debug: (conn, prompt, query, params) => {
        // Optional: log queries if needed for debugging
        // console.log(query);
    }
});

export const db = drizzle(client);
