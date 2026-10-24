import { Router } from 'express';
import { testConnection } from '../config/db.js';
import { success } from '../utils/response.js';

const router = Router();

/**
 * GET /api/v1/health
 *
 * Returns server status and database connectivity.
 * This endpoint is always available — it does not require authentication.
 */
router.get('/health', async (_req, res, next) => {
  try {
    const dbStatus = await testConnection();

    success(res, {
      status: 'ok',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
      database: dbStatus,
    });
  } catch (error) {
    next(error);
  }
});

export default router;
