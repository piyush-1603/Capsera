import { Outlet } from 'react-router-dom';
import Navbar from '../components/Navbar.jsx';

/**
 * MainLayout — shared application shell.
 *
 * Wraps all pages with a consistent navbar and footer.
 * Each member's pages render inside the <Outlet />.
 */
function MainLayout() {
  return (
    <div className="app-layout">
      <Navbar />
      <main className="app-main">
        <Outlet />
      </main>
      <footer className="app-footer">
        <div className="container">
          <p>&copy; {new Date().getFullYear()} CAPSERA — Digital Capacity Building Portal</p>
        </div>
      </footer>
    </div>
  );
}

export default MainLayout;
