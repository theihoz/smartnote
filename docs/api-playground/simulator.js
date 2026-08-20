const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const quotes = [
  { text: 'Small steps every day become big results.', author: 'SmartNote' },
  { text: 'Ideas grow when they are written down.', author: 'SmartNote' },
  { text: 'Focus on progress, not perfection.', author: 'SmartNote' },
];

export function createApiSimulator() {
  const notesByDevice = new Map();

  return {
    request({ method = 'GET', path, deviceId, body }) {
      const requestId = globalThis.crypto?.randomUUID?.() ?? '00000000-0000-4000-8000-000000000000';
      const success = (data, status = 200) => ({ status, body: { data, meta: { requestId } } });
      const failure = (status, code, message) => ({ status, body: { error: { code, message, requestId } } });
      const url = new URL(path, 'https://smartnote.local');

      if (method === 'GET' && url.pathname === '/health') return success({ status: 'ok' });
      if (method === 'GET' && url.pathname === '/v1/quotes/random') {
        return success(quotes[Math.floor(Math.random() * quotes.length)]);
      }
      if (!uuidPattern.test(deviceId ?? '')) {
        return failure(400, 'INVALID_DEVICE_ID', 'X-Device-Id must be a UUID.');
      }

      const notes = notesByDevice.get(deviceId) ?? new Map();
      notesByDevice.set(deviceId, notes);
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
