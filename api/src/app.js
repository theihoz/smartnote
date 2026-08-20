import { randomUUID } from 'node:crypto';
import { DatabaseSync } from 'node:sqlite';

import express from 'express';

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const quotes = [
  { text: 'Small steps every day become big results.', author: 'SmartNote' },
  { text: 'Ideas grow when they are written down.', author: 'SmartNote' },
  { text: 'Focus on progress, not perfection.', author: 'SmartNote' },
];

export function createApp({ databasePath = 'api/data/smartnote-api.db', log = console.log } = {}) {
  const database = new DatabaseSync(databasePath);
  database.exec('PRAGMA journal_mode = WAL; PRAGMA busy_timeout = 5000;');
  database.exec(`
    CREATE TABLE IF NOT EXISTS notes (
      device_id TEXT NOT NULL,
      note_id TEXT NOT NULL,
      payload TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT,
      PRIMARY KEY (device_id, note_id)
    )
  `);

  const app = express();
  app.use((request, response, next) => {
    const origin = request.get('origin');
    if (origin && isAllowedOrigin(origin)) {
      response.setHeader('access-control-allow-origin', origin);
      response.setHeader('vary', 'Origin');
      response.setHeader('access-control-allow-methods', 'GET, PUT, DELETE, OPTIONS');
      response.setHeader('access-control-allow-headers', 'Content-Type, X-Device-Id');
    }
    if (request.method === 'OPTIONS') return response.sendStatus(204);
    next();
  });
  app.use(express.json({ limit: '1mb' }));
  app.use((request, response, next) => {
    request.requestId = randomUUID();
    const startedAt = performance.now();
    response.setHeader('x-request-id', request.requestId);
    response.on('finish', () => log(JSON.stringify({
      requestId: request.requestId,
      method: request.method,
      path: request.path,
      status: response.statusCode,
      durationMs: Math.round(performance.now() - startedAt),
      device: shortDeviceId(request.get('x-device-id')),
    })));
    next();
  });

  app.get('/health', (request, response) => success(response, request, { status: 'ok' }));
  app.get('/v1/quotes/random', (request, response) => {
    success(response, request, quotes[Math.floor(Math.random() * quotes.length)]);
  });

  app.use('/v1/notes', (request, response, next) => {
    const deviceId = request.get('x-device-id');
    if (!deviceId || !uuidPattern.test(deviceId)) {
      return failure(response, request, 400, 'INVALID_DEVICE_ID', 'X-Device-Id must be a UUID.');
    }
    request.deviceId = deviceId;
    next();
  });

  app.get('/v1/notes', (request, response) => {
    const updatedAfter = request.query.updatedAfter;
    if (updatedAfter && !isTimestamp(updatedAfter)) {
      return failure(response, request, 400, 'INVALID_TIMESTAMP', 'updatedAfter must be ISO-8601.');
    }
    const rows = updatedAfter
      ? database.prepare('SELECT payload, deleted_at FROM notes WHERE device_id = ? AND updated_at > ? ORDER BY updated_at').all(request.deviceId, updatedAfter)
      : database.prepare('SELECT payload, deleted_at FROM notes WHERE device_id = ? ORDER BY updated_at').all(request.deviceId);
    success(response, request, rows.map(toResponseNote));
  });

  app.get('/v1/notes/:id', (request, response) => {
    const row = database.prepare('SELECT payload, deleted_at FROM notes WHERE device_id = ? AND note_id = ?').get(request.deviceId, request.params.id);
    if (!row) return failure(response, request, 404, 'NOTE_NOT_FOUND', 'Note not found.');
    success(response, request, toResponseNote(row));
  });

  app.put('/v1/notes/:id', (request, response) => {
    const note = request.body;
    if (!isValidNote(note) || note.id !== request.params.id) {
      return failure(response, request, 400, 'INVALID_NOTE', 'The note payload is invalid.');
    }
    database.prepare(`
      INSERT INTO notes (device_id, note_id, payload, updated_at, deleted_at)
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(device_id, note_id) DO UPDATE SET
        payload = excluded.payload,
        updated_at = excluded.updated_at,
        deleted_at = excluded.deleted_at
      WHERE excluded.updated_at >= notes.updated_at
    `).run(request.deviceId, note.id, JSON.stringify(note), note.updatedAt, note.deletedAt ?? null);
    const row = database.prepare('SELECT payload, deleted_at FROM notes WHERE device_id = ? AND note_id = ?').get(request.deviceId, note.id);
    success(response, request, toResponseNote(row));
  });

  app.delete('/v1/notes/:id', (request, response) => {
    const row = database.prepare('SELECT payload FROM notes WHERE device_id = ? AND note_id = ?').get(request.deviceId, request.params.id);
    if (!row) return failure(response, request, 404, 'NOTE_NOT_FOUND', 'Note not found.');
    const deletedAt = new Date().toISOString();
    const note = { ...JSON.parse(row.payload), deletedAt, updatedAt: deletedAt };
    database.prepare('UPDATE notes SET payload = ?, updated_at = ?, deleted_at = ? WHERE device_id = ? AND note_id = ?')
      .run(JSON.stringify(note), deletedAt, deletedAt, request.deviceId, request.params.id);
    success(response, request, note);
  });

  app.use((error, request, response, _next) => {
    log(JSON.stringify({ requestId: request.requestId, error: error.name }));
    failure(response, request, error instanceof SyntaxError ? 400 : 500, error instanceof SyntaxError ? 'INVALID_JSON' : 'INTERNAL_ERROR', error instanceof SyntaxError ? 'Request body must be valid JSON.' : 'Unexpected server error.');
  });

  return app;
}

function success(response, request, data) {
  response.json({ data, meta: { requestId: request.requestId } });
}

function failure(response, request, status, code, message) {
  response.status(status).json({ error: { code, message, requestId: request.requestId } });
}

function shortDeviceId(value) {
  return typeof value === 'string' && value.length >= 8 ? value.slice(0, 8) : null;
}

function isTimestamp(value) {
  return typeof value === 'string' && !Number.isNaN(Date.parse(value));
}

function isAllowedOrigin(origin) {
  return origin === 'https://theihoz.github.io'
    || /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
}

function isValidNote(note) {
  return note && uuidPattern.test(note.id) && typeof note.title === 'string' && note.title.length <= 500
    && typeof note.body === 'string' && note.body.length <= 100000
    && ['text', 'checklist'].includes(note.kind)
    && Array.isArray(note.checklist) && Array.isArray(note.tags) && Array.isArray(note.imagePaths)
    && typeof note.isFavorite === 'boolean' && typeof note.isLocked === 'boolean'
    && typeof note.colorKey === 'string' && isTimestamp(note.createdAt) && isTimestamp(note.updatedAt)
    && (note.deletedAt == null || isTimestamp(note.deletedAt));
}

function toResponseNote(row) {
  return { ...JSON.parse(row.payload), deletedAt: row.deleted_at };
}
