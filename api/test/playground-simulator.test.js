import assert from 'node:assert/strict';
import test from 'node:test';

import { createApiSimulator } from '../../docs/api-playground/simulator.js';

const deviceId = '11111111-1111-4111-8111-111111111111';
const otherDeviceId = '33333333-3333-4333-8333-333333333333';
const noteId = '22222222-2222-4222-8222-222222222222';

test('simulator supports CRUD, device isolation and tombstones', () => {
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
  assert.equal(api.request({ method: 'PUT', path: `/v1/notes/${noteId}`, deviceId, body: note }).status, 200);
  assert.equal(api.request({ method: 'GET', path: '/v1/notes', deviceId }).body.data.length, 1);
  assert.equal(api.request({ method: 'GET', path: '/v1/notes', deviceId: otherDeviceId }).body.data.length, 0);

  const deleted = api.request({ method: 'DELETE', path: `/v1/notes/${noteId}`, deviceId });
  assert.equal(deleted.status, 200);
  assert.equal(typeof deleted.body.data.deletedAt, 'string');
});
