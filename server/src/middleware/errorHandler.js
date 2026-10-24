/**
 * Centralized error-handling middleware.
 *
 * All errors thrown or passed via next(err) end up here.
 * Returns the standard CAPSERA error envelope:
 *   { success: false, error: { code, message } }
 */

const errorHandler = (err, _req, res, _next) => {
  // Log the full error in development; keep production logs minimal
  if (process.env.NODE_ENV !== 'production') {
    console.error('[Error]', err);
  } else {
    console.error('[Error]', err.message);
  }

  const statusCode = err.statusCode || 500;
  const code = err.code || 'INTERNAL_ERROR';
  const message =
    statusCode === 500 && process.env.NODE_ENV === 'production'
      ? 'An unexpected error occurred'
      : err.message || 'An unexpected error occurred';

  res.status(statusCode).json({
    success: false,
    error: { code, message },
  });
};

export default errorHandler;
