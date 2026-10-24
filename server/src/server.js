import app from './app.js';
import config from './config/env.js';
import { testConnection } from './config/db.js';

const start = async () => {
  console.log(`\n🚀 CAPSERA Server starting in ${config.env} mode...\n`);

  // Test database connection (non-blocking — server starts even if DB is down)
  const dbStatus = await testConnection();
  if (dbStatus.connected) {
    console.log('✅ Database connected successfully');
  } else {
    console.warn('⚠️  Database connection failed:', dbStatus.error);
    console.warn('   The server will start, but database-dependent routes will not work.');
    console.warn('   Ensure MySQL is running and .env is configured correctly.\n');
  }

  app.listen(config.port, () => {
    console.log(`\n✅ Server listening on http://localhost:${config.port}`);
    console.log(`   Health check: http://localhost:${config.port}/api/v1/health\n`);
  });
};

start().catch((err) => {
  console.error('❌ Failed to start server:', err);
  process.exit(1);
});
