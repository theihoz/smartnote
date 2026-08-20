import assert from 'node:assert/strict';
import test from 'node:test';

import { createApiSimulator } from '../../docs/api-playground/simulator.js';

const deviceId = '11111111-1111-4111-8111-111111111111';
const otherDeviceId = '33333333-3333-4333-8333-333333333333';
const noteId = '22222222-2222-4222-8222-222222222222';

test('simulator supports guest auth, CRUD, isolation and tombstones', () => {
  const api = createApiSimulator();
  const note = {
    id: noteId,
    title: 'API Playground',
    body: 'Response mô phỏng',
    kind: 'text',
    checklist: [],
    tags: ['Demo'],
    imagePaths: [],
    isFavorite: false,
    isLocked: false,
    colorKey: 'lavender',
    createdAt: '2026-08-20T00:00:00.000Z',
    updatedAt: '2026-08-20T00:00:00.000Z',
    deletedAt: null,
  };

  assert.equal(api.request({ method: 'GET', path: '/health' }).status, 200);
  const account = api.request({ method: 'POST', path: '/v1/auth/register', body: { email: 'demo@example.com', password: 'password-123' } });
  assert.equal(account.status, 201);
  assert.ok(account.body.data.accessToken);
  const token = api.request({ method: 'POST', path: '/v1/auth/guest', body: { deviceId } }).body.data.accessToken;
  const otherToken = api.request({ method: 'POST', path: '/v1/auth/guest', body: { deviceId: otherDeviceId } }).body.data.accessToken;
  assert.equal(api.request({ method: 'PUT', path: `/v1/notes/${noteId}`, token, body: note }).status, 200);
  assert.equal(api.request({ method: 'GET', path: '/v1/notes', token }).body.data.length, 1);
  assert.equal(api.request({ method: 'GET', path: '/v1/notes', token: otherToken }).body.data.length, 0);

  const deleted = api.request({ method: 'DELETE', path: `/v1/notes/${noteId}`, token });
  assert.equal(deleted.status, 200);
  assert.equal(typeof deleted.body.data.deletedAt, 'string');
});
