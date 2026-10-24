import { Link } from 'react-router-dom';
import './Navbar.css';

/**
 * Navbar — top navigation bar.
 *
 * Placeholder navigation links. Each member adds their module's
 * links here as features are implemented.
 */
function Navbar() {
  return (
    <nav className="navbar" role="navigation" aria-label="Main navigation">
      <div className="container navbar-inner">
        <Link to="/" className="navbar-brand">
          CAPSERA
        </Link>
        <ul className="navbar-links">
          <li><Link to="/">Home</Link></li>
          {/* Member 1: Login/Signup links */}
          {/* Member 2: Courses link */}
          {/* Member 3: Assessments link */}
          {/* Member 4: Dashboard link */}
        </ul>
      </div>
    </nav>
  );
}

export default Navbar;
