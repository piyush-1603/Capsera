import { useEffect, useState } from 'react';
import { getHealth } from '../services/api.js';
import './HomePage.css';

/**
 * HomePage — CAPSERA welcome page with backend health check.
 */
function HomePage() {
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const checkHealth = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await getHealth();
        setHealth(data);
      } catch (err) {
        setError(err.message || 'Failed to connect to the backend');
      } finally {
        setLoading(false);
      }
    };

    checkHealth();
  }, []);

  return (
    <div className="home-page container">
      <section className="hero">
        <h1>Welcome to CAPSERA</h1>
        <p className="hero-subtitle">
          Digital Capacity Building and Learning Management Portal
        </p>
        <p className="hero-description">
          Centralized training, competency development, and knowledge sharing
          for trainees, trainers, and administrators.
        </p>
      </section>

      <section className="features-grid">
        <div className="feature-card">
          <h3>📚 Courses &amp; Learning</h3>
          <p>Discover and enroll in training courses with structured lessons and resources.</p>
        </div>
        <div className="feature-card">
          <h3>📝 Assessments</h3>
          <p>Take MCQ assessments with server-side scoring and track your results.</p>
        </div>
        <div className="feature-card">
          <h3>🎯 Competency Matching</h3>
          <p>Find the right trainers based on skills and expertise mapping.</p>
        </div>
        <div className="feature-card">
          <h3>📜 Certificates</h3>
          <p>Earn verifiable completion certificates upon meeting eligibility criteria.</p>
        </div>
      </section>

      <section className="health-check">
        <h2>System Status</h2>
        {loading && (
          <div className="status-card status-loading" role="status">
            <span className="spinner" aria-hidden="true"></span>
            Checking backend connection…
          </div>
        )}
        {error && (
          <div className="status-card status-error" role="alert">
            <strong>Backend unavailable:</strong> {error}
            <p className="status-hint">
              Make sure the server is running: <code>cd server &amp;&amp; npm run dev</code>
            </p>
          </div>
        )}
        {health && !error && (
          <div className="status-card status-success">
            <p><strong>Server:</strong> ✅ Connected ({health.environment})</p>
            <p>
              <strong>Database:</strong>{' '}
              {health.database?.connected
                ? '✅ Connected'
                : `⚠️ Not connected — ${health.database?.error || 'Check PostgreSQL configuration'}`}
            </p>
            <p className="status-timestamp">
              Last checked: {new Date(health.timestamp).toLocaleString()}
            </p>
          </div>
        )}
      </section>
    </div>
  );
}

export default HomePage;
