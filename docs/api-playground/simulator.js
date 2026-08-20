const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const quotes = [
  { text: 'Small steps every day become big results.', author: 'SmartNote' },
  { text: 'Ideas grow when they are written down.', author: 'SmartNote' },
  { text: 'Focus on progress, not perfection.', author: 'SmartNote' },
];

export function createApiSimulator() {
  const notesByOwner = new Map();
  const sessions = new Map();
  const users = new Map();

  return {
    request({ method = 'GET', path, token, body }) {
      const requestId = globalThis.crypto?.randomUUID?.() ?? '00000000-0000-4000-8000-000000000000';
      const success = (data, status = 200) => ({ status, body: { data, meta: { requestId } } });
      const failure = (status, code, message) => ({ status, body: { error: { code, message, requestId } } });
      const url = new URL(path, 'https://smartnote.local');

      if (method === 'GET' && url.pathname === '/health') return success({ status: 'ok' });
      if (method === 'GET' && url.pathname === '/v1/quotes/random') {
        return success(quotes[Math.floor(Math.random() * quotes.length)]);
      }
      if (method === 'POST' && url.pathname === '/v1/auth/guest') {
        if (!uuidPattern.test(body?.deviceId ?? '')) return failure(400, 'INVALID_DEVICE_ID', 'deviceId must be a UUID.');
        const accessToken = `guest-${body.deviceId}`;
        sessions.set(accessToken, body.deviceId);
        return success({ accessToken, guestSecret: 'mock-guest-secret', expiresAt: '2099-01-01T00:00:00.000Z' });
      }
      if (method === 'POST' && url.pathname === '/v1/auth/register') {
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(body?.email ?? '') || (body?.password?.length ?? 0) < 8) {
          return failure(400, 'INVALID_CREDENTIALS', 'Email or password is invalid.');
        }
        users.set(body.email, { password: body.password });
        const accessToken = `user-${body.email}`;
        sessions.set(accessToken, body.email);
        return success({ user: { id: body.email, email: body.email }, accessToken, expiresAt: '2099-01-01T00:00:00.000Z' }, 201);
      }
      if (method === 'POST' && url.pathname === '/v1/auth/login') {
        const user = users.get(body?.email);
        if (!user || user.password !== body?.password) return failure(401, 'INVALID_LOGIN', 'Email or password is incorrect.');
        const accessToken = `user-${body.email}`;
        sessions.set(accessToken, body.email);
        return success({ user: { id: body.email, email: body.email }, accessToken, expiresAt: '2099-01-01T00:00:00.000Z' });
      }

      const owner = sessions.get(token);
      if (!owner) return failure(401, 'UNAUTHORIZED', 'A valid access token is required.');

      const notes = notesByOwner.get(owner) ?? new Map();
      notesByOwner.set(owner, notes);
      if (method === 'GET' && url.pathname === '/v1/notes') {
        const updatedAfter = url.searchParams.get('updatedAfter');
        const values = [...notes.values()].filter(
          (note) => !updatedAfter || note.updatedAt > updatedAfter,
        );
        return success(values.sort((a, b) => a.updatedAt.localeCompare(b.updatedAt)));
      }

      const match = url.pathname.match(/^\/v1\/notes\/([^/]+)$/);
      if (!match) return failure(404, 'NOT_FOUND', 'Endpoint not found.');
      const noteId = match[1];
      if (method === 'PUT') {
        if (!body || body.id !== noteId) return failure(400, 'INVALID_NOTE', 'The note payload is invalid.');
        const current = notes.get(noteId);
        if (!current || body.updatedAt >= current.updatedAt) notes.set(noteId, structuredClone(body));
        return success(notes.get(noteId));
      }
      if (!notes.has(noteId)) return failure(404, 'NOTE_NOT_FOUND', 'Note not found.');
      if (method === 'GET') return success(notes.get(noteId));
      if (method === 'DELETE') {
        const deletedAt = new Date().toISOString();
        const tombstone = { ...notes.get(noteId), deletedAt, updatedAt: deletedAt };
        notes.set(noteId, tombstone);
        return success(tombstone);
      }
      return failure(405, 'METHOD_NOT_ALLOWED', 'Method not allowed.');
    },
  };
}
