import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import dotenv from "dotenv";

dotenv.config();

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
    throw new Error("DATABASE_URL is not defined");
}

console.log('Initializing database connection...');

// Fix: Supabase Transaction Pooler (6543) often times out on Render.
// We automatically switch to Session Mode (5432) for better stability in this Node enviroment.
let realConnectionString = connectionString;
if (connectionString.includes(':6543')) {
    console.log('⚠️ Detected Transaction Pooler port (6543). Switching to Direct Connection (5432) for stability.');
    realConnectionString = connectionString.replace(':6543', ':5432');
}

// Mask the password for logging
const maskedString = realConnectionString.replace(/:([^@]+)@/, ':****@');
console.log(`DATABASE_URL (Used): ${maskedString}`);

const client = postgres(realConnectionString, {
    prepare: false, // Keep false for compatibility
    ssl: 'require',
    connect_timeout: 30, // Increase timeout to 30s
    keep_alive: 20
});

export const db = drizzle(client);
