import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import config from './config/env.js';
import apiRoutes from './routes/index.js';
import notFound from './middleware/notFound.js';
import errorHandler from './middleware/errorHandler.js';

const app = express();

// ─── Security Headers ───
app.use(helmet());

// ─── CORS ───
app.use(
  cors({
    origin: config.cors.origin,
    credentials: true,
  })
);

// ─── Body Parsing ───
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ─── API Routes ───
app.use('/api/v1', apiRoutes);

// ─── 404 Handler ───
app.use(notFound);

// ─── Centralized Error Handler ───
app.use(errorHandler);

export default app;
