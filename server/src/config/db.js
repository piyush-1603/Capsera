import pkg from 'pg';
const { Pool } = pkg;
import config from './env.js';

/**
 * PostgreSQL connection pool using pg.
 *
 * The pool is created lazily — calling getPool() for the first time
 * creates the pool. The server can start without a database connection;
 * database-dependent routes will fail clearly if PostgreSQL is unavailable.
 */

let pool = null;

export const getPool = () => {
  if (!pool) {
    pool = new Pool({
      host: config.db.host,
      port: config.db.port,
      user: config.db.user,
      password: config.db.password || undefined,
      database: config.db.name,
      max: 10,
      idleTimeoutMillis: 30000,
    });
  }
  return pool;
};

/**
 * Test database connectivity.
 * Returns { connected: true } on success, or { connected: false, error } on failure.
 */
export const testConnection = async () => {
  try {
    const client = await getPool().connect();
    await client.query('SELECT 1');
    client.release();
    return { connected: true };
  } catch (error) {
    return { connected: false, error: error.message };
  }
};
