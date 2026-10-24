import { describe, it, expect } from 'vitest';
import request from 'supertest';
import app from '../src/app.js';

describe('GET /api/v1/health', () => {
  it('should return success with server status', async () => {
    const res = await request(app).get('/api/v1/health');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.status).toBe('ok');
    expect(res.body.data.timestamp).toBeDefined();
    expect(res.body.data.environment).toBeDefined();
    expect(res.body.data.database).toBeDefined();
  });

  it('should include database connectivity info', async () => {
    const res = await request(app).get('/api/v1/health');

    expect(res.body.data.database).toHaveProperty('connected');
  });
});

describe('404 handling', () => {
  it('should return 404 for unknown routes', async () => {
    const res = await request(app).get('/api/v1/nonexistent');

    expect(res.status).toBe(404);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('NOT_FOUND');
  });
});

describe('Response format', () => {
  it('should follow the standard success envelope', async () => {
    const res = await request(app).get('/api/v1/health');

    expect(res.body).toHaveProperty('success');
    expect(res.body).toHaveProperty('data');
    expect(typeof res.body.success).toBe('boolean');
    expect(typeof res.body.data).toBe('object');
  });

  it('should follow the standard error envelope', async () => {
    const res = await request(app).get('/api/v1/nonexistent');

    expect(res.body).toHaveProperty('success', false);
    expect(res.body).toHaveProperty('error');
    expect(res.body.error).toHaveProperty('code');
    expect(res.body.error).toHaveProperty('message');
  });
});
