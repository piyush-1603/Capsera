import { BrowserRouter, Routes, Route } from 'react-router-dom';
import MainLayout from './layouts/MainLayout.jsx';
import HomePage from './pages/HomePage.jsx';
import NotFoundPage from './pages/NotFoundPage.jsx';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<MainLayout />}>
          <Route path="/" element={<HomePage />} />
          {/* ─── Member 1: Auth Pages ─── */}
          {/* <Route path="/login" element={<LoginPage />} /> */}
          {/* <Route path="/signup" element={<SignupPage />} /> */}

          {/* ─── Member 2: Course Pages ─── */}
          {/* <Route path="/courses" element={<CoursesPage />} /> */}

          {/* ─── Member 3: Assessment Pages ─── */}
          {/* <Route path="/assessments" element={<AssessmentsPage />} /> */}

          {/* ─── Member 4: Skills/Dashboard Pages ─── */}
          {/* <Route path="/dashboard" element={<DashboardPage />} /> */}

          <Route path="*" element={<NotFoundPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
