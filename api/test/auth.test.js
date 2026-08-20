import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';

import { createApp } from '../src/app.js';

let baseUrl;
let server;

before(async () => {
  const app = createApp({
    databasePath: ':memory:',
    log: () => {},
  });
  server = app.listen(0);
  await new Promise((resolve) => server.once('listening', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(() => server?.close());

async function request(path, { token, guestToken, ...options } = {}) {
  const response = await fetch(`${baseUrl}${path}`, {
    ...options,
    headers: {
      'content-type': 'application/json',
      ...(token ? { authorization: `Bearer ${token}` } : {}),
      ...(guestToken ? { 'x-guest-token': guestToken } : {}),
      ...options.headers,
    },
  });
  const text = await response.text();
  return { response, body: text.startsWith('{') ? JSON.parse(text) : { raw: text } };
}

async function register(email = 'owner@example.com') {
  const result = await request('/v1/auth/register', {
    method: 'POST',
    body: JSON.stringify({ email, password: 'correct horse battery staple' }),
  });
  assert.equal(result.response.status, 201);
  return result.body.data.accessToken;
}

test('register validates email format and signs the account in immediately', async () => {
  const email = 'owner-now@example.com';
  let result = await request('/v1/auth/register', {
    method: 'POST',
    body: JSON.stringify({ email: ` ${email.toUpperCase()} `, password: 'password-123' }),
  });
  assert.equal(result.response.status, 201);
  assert.equal(result.body.data.user.email, email);
  assert.ok(result.body.data.accessToken);

  result = await request('/v1/auth/me', { token: result.body.data.accessToken });
  assert.equal(result.response.status, 200);
  assert.equal(result.body.data.email, email);

  result = await request('/v1/auth/register', {
    method: 'POST', body: JSON.stringify({ email: 'not-an-email', password: 'password-123' }),
  });
  assert.equal(result.response.status, 400);
  assert.equal(result.body.error.code, 'INVALID_CREDENTIALS');
});

test('registered account can login without verification', async () => {
  const email = 'login-now@example.com';
  await register(email);
  const result = await request('/v1/auth/login', {
    method: 'POST', body: JSON.stringify({ email, password: 'correct horse battery staple' }),
  });
  assert.equal(result.response.status, 200);
  assert.ok(result.body.data.accessToken);
});

test('duplicate registration is rejected', async () => {
  const email = 'limited@example.com';
  let result = await request('/v1/auth/register', {
    method: 'POST', body: JSON.stringify({ email, password: 'password-123' }),
  });
  assert.equal(result.response.status, 201);
  result = await request('/v1/auth/register', {
    method: 'POST', body: JSON.stringify({ email, password: 'password-123' }),
  });
  assert.equal(result.response.status, 409);
});

test('login, me, password change and logout manage sessions', async () => {
  const token = await register();
  let result = await request('/v1/auth/me', { token });
  assert.equal(result.body.data.email, 'owner@example.com');

  result = await request('/v1/auth/password', {
    token,
    method: 'PUT',
    body: JSON.stringify({ currentPassword: 'correct horse battery staple', newPassword: 'new-password-123' }),
  });
  assert.equal(result.response.status, 200);

  result = await request('/v1/auth/login', {
    method: 'POST', body: JSON.stringify({ email: 'owner@example.com', password: 'new-password-123' }),
  });
  assert.equal(result.response.status, 200);
  const nextToken = result.body.data.accessToken;

  result = await request('/v1/auth/logout', { token: nextToken, method: 'POST' });
  assert.equal(result.response.status, 200);
  result = await request('/v1/auth/me', { token: nextToken });
  assert.equal(result.response.status, 401);
});

test('guest data is isolated then claimed by an account', async () => {
  const deviceId = '11111111-1111-4111-8111-111111111111';
  let result = await request('/v1/auth/guest', {
    method: 'POST', body: JSON.stringify({ deviceId }),
  });
  assert.equal(result.response.status, 200);
  const guestToken = result.body.data.accessToken;
  const note = {
    id: '22222222-2222-4222-8222-222222222222', title: 'Guest note', body: '', kind: 'text',
    checklist: [], tags: [], imagePaths: [], isFavorite: false, isLocked: false,
    colorKey: 'sage', createdAt: '2026-08-20T00:00:00.000Z', updatedAt: '2026-08-20T00:00:00.000Z',
  };
  result = await request(`/v1/notes/${note.id}`, {
    token: guestToken, method: 'PUT', body: JSON.stringify(note),
  });
  assert.equal(result.response.status, 200);

  const accountToken = await register('claim@example.com');
  result = await request('/v1/auth/claim-guest', {
    token: accountToken, guestToken, method: 'POST', body: '{}',
  });
  assert.equal(result.response.status, 200);
  assert.equal(result.body.data.claimed, 1);

  result = await request('/v1/notes', { token: accountToken });
  assert.equal(result.body.data[0].title, 'Guest note');
  result = await request('/v1/notes', { token: guestToken });
  assert.equal(result.response.status, 401);
});
