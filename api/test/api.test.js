import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';

import { createApp } from '../src/app.js';

let baseUrl;
let server;
let token;

before(async () => {
  const app = createApp({ databasePath: ':memory:', log: () => {} });
  server = app.listen(0);
  await new Promise((resolve) => server.once('listening', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
  const response = await fetch(`${baseUrl}/v1/auth/guest`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ deviceId: '11111111-1111-4111-8111-111111111111' }),
  });
  token = (await response.json()).data.accessToken;
});

after(() => server?.close());

async function request(path, options = {}) {
  return fetch(`${baseUrl}${path}`, {
    ...options,
    headers: {
      'content-type': 'application/json',
      ...(token ? { authorization: `Bearer ${token}` } : {}),
      ...options.headers,
    },
  });
}

test('health returns a request id', async () => {
  const response = await request('/health');
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.data.status, 'ok');
  assert.match(body.meta.requestId, /^[0-9a-f-]{36}$/);
});

test('allows the GitHub Pages playground without reflecting other origins', async () => {
  let response = await request('/health', {
    headers: { origin: 'https://theihoz.github.io' },
  });
  assert.equal(
    response.headers.get('access-control-allow-origin'),
    'https://theihoz.github.io',
  );

  response = await request('/v1/notes', {
    method: 'OPTIONS',
    headers: {
      origin: 'https://theihoz.github.io',
      'access-control-request-method': 'GET',
    },
  });
  assert.equal(response.status, 204);
  assert.match(
    response.headers.get('access-control-allow-headers'),
    /Authorization/i,
  );

  response = await request('/health', {
    headers: { origin: 'https://example.com' },
  });
  assert.equal(response.headers.get('access-control-allow-origin'), null);
});

test('upsert, pull and delete a note for one device', async () => {
  const note = {
    id: '22222222-2222-4222-8222-222222222222',
    title: 'API note',
    body: 'Stored by the backend',
    kind: 'text',
    checklist: [],
    tags: ['api'],
    imagePaths: [],
    isFavorite: false,
    isLocked: false,
    colorKey: 'lavender',
    createdAt: '2026-08-20T00:00:00.000Z',
    updatedAt: '2026-08-20T00:00:00.000Z'
  };

  let response = await request(`/v1/notes/${note.id}`, {
    method: 'PUT',
    body: JSON.stringify(note),
  });
  assert.equal(response.status, 200);

  response = await request('/v1/notes');
  let body = await response.json();
  assert.equal(body.data.length, 1);
  assert.equal(body.data[0].title, 'API note');

  response = await request(`/v1/notes/${note.id}`, { method: 'DELETE' });
  assert.equal(response.status, 200);

  response = await request('/v1/notes');
  body = await response.json();
  assert.ok(body.data[0].deletedAt);
});

test('another guest session is isolated', async () => {
  let response = await fetch(`${baseUrl}/v1/auth/guest`, {
    method: 'POST', headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ deviceId: '33333333-3333-4333-8333-333333333333' }),
  });
  const otherToken = (await response.json()).data.accessToken;
  response = await request('/v1/notes', { headers: { authorization: `Bearer ${otherToken}` } });
  const body = await response.json();
  assert.deepEqual(body.data, []);
});

test('invalid token returns a stable error envelope', async () => {
  const response = await request('/v1/notes', {
    headers: { authorization: 'Bearer invalid' },
  });
  const body = await response.json();

  assert.equal(response.status, 401);
  assert.equal(body.error.code, 'UNAUTHORIZED');
  assert.ok(body.error.requestId);
});

test('quote endpoint returns text and author', async () => {
  const response = await request('/v1/quotes/random');
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(typeof body.data.text, 'string');
  assert.equal(typeof body.data.author, 'string');
});
