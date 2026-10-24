import axios from 'axios';

/**
 * CAPSERA API service.
 *
 * Centralized HTTP client configured with the backend base URL.
 * All API calls should use this client to ensure consistent
 * configuration, error handling, and future auth header injection.
 *
 * Team members: import { api } from '../services/api.js' and use
 * api.get(), api.post(), etc. for your module's API calls.
 */

const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000/api/v1';

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,
});

// ─── Response Interceptor ───
// Unwraps the CAPSERA { success, data } envelope so callers
// receive `data` directly. Errors are formatted consistently.
api.interceptors.response.use(
  (response) => {
    // Successful responses: unwrap the envelope
    if (response.data && response.data.success) {
      return response.data.data;
    }
    return response.data;
  },
  (error) => {
    // Extract the CAPSERA error envelope if available
    const serverError = error.response?.data?.error;
    const message = serverError?.message || error.message || 'Network error';
    const code = serverError?.code || 'NETWORK_ERROR';

    const apiError = new Error(message);
    apiError.code = code;
    apiError.status = error.response?.status;
    return Promise.reject(apiError);
  }
);

// ─── Health Check ───
export const getHealth = () => api.get('/health');

export default api;
