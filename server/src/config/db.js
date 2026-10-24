import mysql from 'mysql2/promise';
import config from './env.js';

/**
 * MySQL connection pool using mysql2/promise.
 *
 * The pool is created lazily — calling getPool() for the first time
 * creates the pool. The server can start without a database connection;
 * database-dependent routes will fail clearly if MySQL is unavailable.
 */

let pool = null;

export const getPool = () => {
  if (!pool) {
    pool = mysql.createPool({
      host: config.db.host,
      port: config.db.port,
      user: config.db.user,
      password: config.db.password,
      database: config.db.name,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      timezone: '+00:00',
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
    const connection = await getPool().getConnection();
    await connection.ping();
    connection.release();
    return { connected: true };
  } catch (error) {
    return { connected: false, error: error.message };
  }
};
