/**
 * Not-found handler for unmatched routes.
 *
 * Mount this after all other routes. It creates a 404 error
 * and forwards it to the centralized error handler.
 */
const notFound = (req, _res, next) => {
  const error = new Error(`Not found: ${req.method} ${req.originalUrl}`);
  error.statusCode = 404;
  error.code = 'NOT_FOUND';
  next(error);
};

export default notFound;
