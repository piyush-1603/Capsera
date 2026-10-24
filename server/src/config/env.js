import 'dotenv/config';

/**
 * Centralized environment configuration with validation.
 *
 * Required variables will cause the server to report a clear error
 * at startup if they are missing. Optional variables have defaults.
 */

// Used by team members when adding required env vars (e.g., JWT_SECRET)
// eslint-disable-next-line no-unused-vars
const required = (key) => {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
};

const optional = (key, fallback) => process.env[key] || fallback;

const config = {
  env: optional('NODE_ENV', 'development'),
  port: parseInt(optional('PORT', '5000'), 10),

  db: {
    host: optional('DB_HOST', 'localhost'),
    port: parseInt(optional('DB_PORT', '3306'), 10),
    user: optional('DB_USER', 'root'),
    password: optional('DB_PASSWORD', ''),
    name: optional('DB_NAME', 'capsera_db'),
  },

  cors: {
    origin: optional('CORS_ORIGIN', 'http://localhost:5173'),
  },
};

export default config;
