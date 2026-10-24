import { Router } from 'express';
import healthRoutes from './health.js';

/**
 * Central route registration.
 *
 * All API routes are registered here under /api/v1.
 * Each team member adds their module routes by importing
 * their router and mounting it on the appropriate path.
 *
 * Example (Member 1 adding auth routes):
 *   import authRoutes from '../modules/auth/auth.routes.js';
 *   router.use('/auth', authRoutes);
 *
 * Example (Member 3 adding assessment routes):
 *   import assessmentRoutes from '../modules/assessments/assessment.routes.js';
 *   router.use('/assessments', assessmentRoutes);
 */

const router = Router();

// Health check (always available)
router.use('/', healthRoutes);

// ─── Member 1: Auth, Profiles, User Management ───
// router.use('/auth', authRoutes);
// router.use('/profiles', profileRoutes);
// router.use('/admin/users', adminUserRoutes);

// ─── Member 2: Courses, Lessons, Resources, Enrollments ───
// router.use('/courses', courseRoutes);
// router.use('/lessons', lessonRoutes);
// router.use('/enrollments', enrollmentRoutes);

// ─── Member 3: Assessments, Attempts, Results, Feedback ───
// router.use('/assessments', assessmentRoutes);
// router.use('/attempts', attemptRoutes);
// router.use('/courses', feedbackRoutes); // feedback nested under courses

// ─── Member 4: Skills, Certificates, Announcements, Dashboard ───
// router.use('/skills', skillRoutes);
// router.use('/trainers', trainerRoutes);
// router.use('/certificates', certificateRoutes);
// router.use('/announcements', announcementRoutes);
// router.use('/admin/dashboard', dashboardRoutes);

export default router;
