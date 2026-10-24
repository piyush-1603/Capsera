/**
 * Standard response helpers following CAPSERA API conventions.
 *
 * Success:  { success: true, data: {} }
 * Error:    { success: false, error: { code, message } }
 * Created:  201 + success envelope
 * Paginated: success envelope with items + pagination metadata
 */

export const success = (res, data = {}, statusCode = 200) => {
  res.status(statusCode).json({ success: true, data });
};

export const created = (res, data = {}) => {
  res.status(201).json({ success: true, data });
};

export const paginated = (res, { items, page, pageSize, totalItems }) => {
  const totalPages = Math.ceil(totalItems / pageSize);
  res.status(200).json({
    success: true,
    data: {
      items,
      pagination: { page, pageSize, totalItems, totalPages },
    },
  });
};

/**
 * Create an operational error with statusCode and code for the error handler.
 */
export class AppError extends Error {
  constructor(message, statusCode = 500, code = 'INTERNAL_ERROR') {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
  }
}
