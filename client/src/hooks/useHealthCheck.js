import { useState, useCallback } from 'react';
import { getHealth } from '../services/api.js';

/**
 * useHealthCheck — custom hook for backend health monitoring.
 *
 * Returns { health, loading, error, refetch }.
 * Call refetch() to trigger the health check.
 *
 * Usage:
 *   const { health, loading, error, refetch } = useHealthCheck();
 *   // call refetch() in a useEffect or event handler in the component
 */
export function useHealthCheck() {
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const refetch = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await getHealth();
      setHealth(data);
    } catch (err) {
      setError(err.message || 'Failed to reach the backend');
    } finally {
      setLoading(false);
    }
  }, []);

  return { health, loading, error, refetch };
}
