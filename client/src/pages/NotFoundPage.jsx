import { Link } from 'react-router-dom';

/**
 * NotFoundPage — 404 fallback page.
 */
function NotFoundPage() {
  return (
    <div className="container" style={{ textAlign: 'center', padding: '4rem 1rem' }}>
      <h1 style={{ fontSize: '3rem', color: 'var(--color-text-secondary)' }}>404</h1>
      <p style={{ fontSize: '1.1rem', margin: '1rem 0' }}>Page not found</p>
      <Link to="/" style={{ color: 'var(--color-primary)' }}>
        ← Back to Home
      </Link>
    </div>
  );
}

export default NotFoundPage;
