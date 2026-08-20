import { createHash, pbkdf2Sync, randomBytes, randomUUID, timingSafeEqual } from 'node:crypto';
import { DatabaseSync } from 'node:sqlite';
import express from 'express';

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const quotes = [
  { text: 'Small steps every day become big results.', author: 'SmartNote' },
  { text: 'Ideas grow when they are written down.', author: 'SmartNote' },
  { text: 'Focus on progress, not perfection.', author: 'SmartNote' },
];

export function createApp({ databasePath = 'api/data/smartnote-api.db', log = console.log,
  passwordIterations = 600_000, now = () => new Date() } = {}) {
  const database = new DatabaseSync(databasePath);
  database.exec('PRAGMA journal_mode = WAL; PRAGMA busy_timeout = 5000; PRAGMA foreign_keys = ON;');
  createSchema(database);
  const app = express();

  app.use((request, response, next) => {
    const origin = request.get('origin');
    if (origin && isAllowedOrigin(origin)) {
      response.setHeader('access-control-allow-origin', origin);
      response.setHeader('vary', 'Origin');
      response.setHeader('access-control-allow-methods', 'GET, POST, PUT, DELETE, OPTIONS');
      response.setHeader('access-control-allow-headers', 'Authorization, Content-Type, X-Guest-Token');
    }
    if (request.method === 'OPTIONS') return response.sendStatus(204);
    next();
  });
  app.use(express.json({ limit: '1mb' }));
  app.use((request, response, next) => {
    request.requestId = randomUUID();
    const startedAt = performance.now();
    response.setHeader('x-request-id', request.requestId);
    response.on('finish', () => log(JSON.stringify({ requestId: request.requestId, method: request.method,
      path: request.path, status: response.statusCode, durationMs: Math.round(performance.now() - startedAt),
      owner: request.principalId?.slice(0, 8) ?? null })));
    next();
  });

  const issueSession = (principalId) => {
    const token = randomBytes(32).toString('base64url');
    const expiresAt = new Date(now().getTime() + 30 * 86400000).toISOString();
    database.prepare('INSERT INTO sessions (id, principal_id, token_hash, expires_at, created_at) VALUES (?, ?, ?, ?, ?)')
      .run(randomUUID(), principalId, sha256(token), expiresAt, now().toISOString());
    return { accessToken: token, expiresAt };
  };
  const authenticate = (request, response, next) => {
    const token = bearerToken(request);
    const session = token && database.prepare(`SELECT sessions.id, sessions.principal_id, principals.kind, users.email
      FROM sessions JOIN principals ON principals.id = sessions.principal_id
      LEFT JOIN users ON users.principal_id = principals.id
      WHERE sessions.token_hash = ? AND sessions.expires_at > ?`).get(sha256(token), now().toISOString());
    if (!session) return failure(response, request, 401, 'UNAUTHORIZED', 'A valid access token is required.');
    Object.assign(request, { sessionId: session.id, principalId: session.principal_id,
      principalKind: session.kind, email: session.email ?? null });
    next();
  };

  app.get('/health', (request, response) => success(response, request, { status: 'ok' }));
  app.get('/v1/quotes/random', (request, response) => success(response, request, quotes[Math.floor(Math.random() * quotes.length)]));

  app.post('/v1/auth/guest', (request, response) => {
    const { deviceId, guestSecret: suppliedSecret } = request.body ?? {};
    if (!uuidPattern.test(deviceId ?? '')) return failure(response, request, 400, 'INVALID_DEVICE_ID', 'deviceId must be a UUID.');
    let guest = database.prepare('SELECT principal_id, secret_hash FROM guest_devices WHERE device_id = ?').get(deviceId);
    let guestSecret;
    if (guest && (!suppliedSecret || !safeHashEqual(guest.secret_hash, sha256(suppliedSecret)))) {
      return failure(response, request, 401, 'INVALID_GUEST_SECRET', 'The guest secret is invalid.');
    }
    if (!guest) {
      const principalId = randomUUID();
      guestSecret = randomBytes(32).toString('base64url');
      database.prepare('INSERT INTO principals (id, kind, created_at) VALUES (?, ?, ?)').run(principalId, 'guest', now().toISOString());
      database.prepare('INSERT INTO guest_devices (device_id, principal_id, secret_hash) VALUES (?, ?, ?)').run(deviceId, principalId, sha256(guestSecret));
      guest = { principal_id: principalId };
    }
    success(response, request, { ...issueSession(guest.principal_id), guestSecret });
  });

  app.post('/v1/auth/register', (request, response) => {
    const email = normalizeEmail(request.body?.email);
    const password = request.body?.password;
    if (!isValidEmail(email) || !isValidPassword(password)) return failure(response, request, 400, 'INVALID_CREDENTIALS', 'Email or password is invalid.');
    if (database.prepare('SELECT 1 FROM users WHERE email = ?').get(email)) return failure(response, request, 409, 'EMAIL_EXISTS', 'Email is already registered.');
    const principalId = randomUUID();
    const salt = randomBytes(16).toString('hex');
    const createdAt = now().toISOString();
    database.exec('BEGIN');
    try {
      database.prepare('INSERT INTO principals (id, kind, created_at) VALUES (?, ?, ?)').run(principalId, 'user', createdAt);
      database.prepare('INSERT INTO users (principal_id, email, password_hash, password_salt, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)')
        .run(principalId, email, hashPassword(password, salt, passwordIterations), salt, createdAt, createdAt);
      database.exec('COMMIT');
    } catch (error) { database.exec('ROLLBACK'); throw error; }
    response.status(201);
    success(response, request, { user: { id: principalId, email }, ...issueSession(principalId) });
  });

  app.post('/v1/auth/login', (request, response) => {
    const email = normalizeEmail(request.body?.email);
    const password = request.body?.password;
    const user = database.prepare('SELECT * FROM users WHERE email = ?').get(email);
    if (!user || !verifyPassword(password, user, passwordIterations)) return failure(response, request, 401, 'INVALID_LOGIN', 'Email or password is incorrect.');
    success(response, request, { user: { id: user.principal_id, email }, ...issueSession(user.principal_id) });
  });
  app.post('/v1/auth/logout', authenticate, (request, response) => {
    database.prepare('DELETE FROM sessions WHERE id = ?').run(request.sessionId);
    success(response, request, { loggedOut: true });
  });
  app.get('/v1/auth/me', authenticate, (request, response) => success(response, request,
    { id: request.principalId, kind: request.principalKind, email: request.email }));
  app.put('/v1/auth/password', authenticate, (request, response) => {
    if (request.principalKind !== 'user') return failure(response, request, 403, 'ACCOUNT_REQUIRED', 'A user account is required.');
    const user = database.prepare('SELECT * FROM users WHERE principal_id = ?').get(request.principalId);
    if (!verifyPassword(request.body?.currentPassword, user, passwordIterations)) return failure(response, request, 401, 'INVALID_CURRENT_PASSWORD', 'Current password is incorrect.');
    if (!isValidPassword(request.body?.newPassword)) return failure(response, request, 400, 'INVALID_PASSWORD', 'Password must contain 8 to 72 characters.');
    const salt = randomBytes(16).toString('hex');
    database.prepare('UPDATE users SET password_hash = ?, password_salt = ?, updated_at = ? WHERE principal_id = ?')
      .run(hashPassword(request.body.newPassword, salt, passwordIterations), salt, now().toISOString(), request.principalId);
    database.prepare('DELETE FROM sessions WHERE principal_id = ? AND id <> ?').run(request.principalId, request.sessionId);
    success(response, request, { changed: true });
  });

  app.post('/v1/auth/claim-guest', authenticate, (request, response) => {
    if (request.principalKind !== 'user') return failure(response, request, 403, 'ACCOUNT_REQUIRED', 'A user account is required.');
    const guestToken = request.get('x-guest-token');
    const guest = guestToken && database.prepare(`SELECT sessions.principal_id FROM sessions
      JOIN principals ON principals.id = sessions.principal_id
      WHERE sessions.token_hash = ? AND sessions.expires_at > ? AND principals.kind = 'guest'`)
      .get(sha256(guestToken), now().toISOString());
    if (!guest) return failure(response, request, 401, 'INVALID_GUEST_TOKEN', 'A valid guest token is required.');
    const rows = database.prepare('SELECT * FROM notes WHERE owner_id = ?').all(guest.principal_id);
    const upsert = database.prepare(`INSERT INTO notes (owner_id, note_id, payload, updated_at, deleted_at) VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(owner_id, note_id) DO UPDATE SET payload=excluded.payload, updated_at=excluded.updated_at, deleted_at=excluded.deleted_at
      WHERE excluded.updated_at > notes.updated_at`);
    database.exec('BEGIN');
    try {
      for (const row of rows) upsert.run(request.principalId, row.note_id, row.payload, row.updated_at, row.deleted_at);
      database.prepare('DELETE FROM notes WHERE owner_id = ?').run(guest.principal_id);
      database.prepare('DELETE FROM sessions WHERE principal_id = ?').run(guest.principal_id);
      database.prepare('DELETE FROM principals WHERE id = ?').run(guest.principal_id);
      database.exec('COMMIT');
    } catch (error) { database.exec('ROLLBACK'); throw error; }
    success(response, request, { claimed: rows.length });
  });

  app.use('/v1/notes', authenticate);
  app.get('/v1/notes', (request, response) => {
    const updatedAfter = request.query.updatedAfter;
    if (updatedAfter && !isTimestamp(updatedAfter)) return failure(response, request, 400, 'INVALID_TIMESTAMP', 'updatedAfter must be ISO-8601.');
    const rows = updatedAfter
      ? database.prepare('SELECT payload, deleted_at FROM notes WHERE owner_id = ? AND updated_at > ? ORDER BY updated_at').all(request.principalId, updatedAfter)
      : database.prepare('SELECT payload, deleted_at FROM notes WHERE owner_id = ? ORDER BY updated_at').all(request.principalId);
    success(response, request, rows.map(toResponseNote));
  });
  app.get('/v1/notes/:id', (request, response) => {
    const row = database.prepare('SELECT payload, deleted_at FROM notes WHERE owner_id = ? AND note_id = ?').get(request.principalId, request.params.id);
    if (!row) return failure(response, request, 404, 'NOTE_NOT_FOUND', 'Note not found.');
    success(response, request, toResponseNote(row));
  });
  app.put('/v1/notes/:id', (request, response) => {
    const note = request.body;
    if (!isValidNote(note) || note.id !== request.params.id) return failure(response, request, 400, 'INVALID_NOTE', 'The note payload is invalid.');
    database.prepare(`INSERT INTO notes (owner_id,note_id,payload,updated_at,deleted_at) VALUES (?,?,?,?,?)
      ON CONFLICT(owner_id,note_id) DO UPDATE SET payload=excluded.payload,updated_at=excluded.updated_at,deleted_at=excluded.deleted_at
      WHERE excluded.updated_at >= notes.updated_at`).run(request.principalId, note.id, JSON.stringify(note), note.updatedAt, note.deletedAt ?? null);
    const row = database.prepare('SELECT payload, deleted_at FROM notes WHERE owner_id = ? AND note_id = ?').get(request.principalId, note.id);
    success(response, request, toResponseNote(row));
  });
  app.delete('/v1/notes/:id', (request, response) => {
    const row = database.prepare('SELECT payload FROM notes WHERE owner_id = ? AND note_id = ?').get(request.principalId, request.params.id);
    if (!row) return failure(response, request, 404, 'NOTE_NOT_FOUND', 'Note not found.');
    const deletedAt = now().toISOString();
    const note = { ...JSON.parse(row.payload), deletedAt, updatedAt: deletedAt };
    database.prepare('UPDATE notes SET payload=?, updated_at=?, deleted_at=? WHERE owner_id=? AND note_id=?')
      .run(JSON.stringify(note), deletedAt, deletedAt, request.principalId, request.params.id);
    success(response, request, note);
  });

  app.use((error, request, response, _next) => {
    log(JSON.stringify({ requestId: request.requestId, error: error.name }));
    failure(response, request, error instanceof SyntaxError ? 400 : 500,
      error instanceof SyntaxError ? 'INVALID_JSON' : 'INTERNAL_ERROR',
      error instanceof SyntaxError ? 'Request body must be valid JSON.' : 'Unexpected server error.');
  });
  return app;
}

function createSchema(database) {
  database.exec(`CREATE TABLE IF NOT EXISTS principals(id TEXT PRIMARY KEY,kind TEXT NOT NULL CHECK(kind IN('guest','user')),created_at TEXT NOT NULL);
    CREATE TABLE IF NOT EXISTS users(principal_id TEXT PRIMARY KEY REFERENCES principals(id) ON DELETE CASCADE,email TEXT NOT NULL UNIQUE,password_hash TEXT NOT NULL,password_salt TEXT NOT NULL,created_at TEXT NOT NULL,updated_at TEXT NOT NULL);
    CREATE TABLE IF NOT EXISTS guest_devices(device_id TEXT PRIMARY KEY,principal_id TEXT NOT NULL UNIQUE REFERENCES principals(id) ON DELETE CASCADE,secret_hash TEXT NOT NULL);
    CREATE TABLE IF NOT EXISTS sessions(id TEXT PRIMARY KEY,principal_id TEXT NOT NULL REFERENCES principals(id) ON DELETE CASCADE,token_hash TEXT NOT NULL UNIQUE,expires_at TEXT NOT NULL,created_at TEXT NOT NULL);
    CREATE INDEX IF NOT EXISTS sessions_token_idx ON sessions(token_hash);
    CREATE TABLE IF NOT EXISTS notes(owner_id TEXT NOT NULL REFERENCES principals(id) ON DELETE CASCADE,note_id TEXT NOT NULL,payload TEXT NOT NULL,updated_at TEXT NOT NULL,deleted_at TEXT,PRIMARY KEY(owner_id,note_id));`);
}
function normalizeEmail(value) { return typeof value === 'string' ? value.trim().toLowerCase() : ''; }
function isValidEmail(value) { return value.length <= 254 && emailPattern.test(value); }
function isValidPassword(value) { return typeof value === 'string' && value.length >= 8 && value.length <= 72; }
function hashPassword(password, salt, iterations) { return pbkdf2Sync(password, salt, iterations, 32, 'sha256').toString('hex'); }
function verifyPassword(password, user, iterations) { return user && isValidPassword(password) && safeHashEqual(user.password_hash, hashPassword(password, user.password_salt, iterations)); }
function sha256(value) { return createHash('sha256').update(value).digest('hex'); }
function safeHashEqual(left, right) { const a = Buffer.from(left ?? '', 'hex'); const b = Buffer.from(right ?? '', 'hex'); return a.length === b.length && timingSafeEqual(a, b); }
function bearerToken(request) { const value = request.get('authorization'); return value?.startsWith('Bearer ') ? value.slice(7) : null; }
function success(response, request, data) { response.json({ data, meta: { requestId: request.requestId } }); }
function failure(response, request, status, code, message) { return response.status(status).json({ error: { code, message, requestId: request.requestId } }); }
function isTimestamp(value) { return typeof value === 'string' && !Number.isNaN(Date.parse(value)); }
function isAllowedOrigin(origin) { return origin === 'https://theihoz.github.io' || /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin); }
function isValidNote(note) { return note && uuidPattern.test(note.id) && typeof note.title === 'string' && note.title.length <= 500 && typeof note.body === 'string' && note.body.length <= 100000 && ['text','checklist'].includes(note.kind) && Array.isArray(note.checklist) && Array.isArray(note.tags) && Array.isArray(note.imagePaths) && typeof note.isFavorite === 'boolean' && typeof note.isLocked === 'boolean' && typeof note.colorKey === 'string' && isTimestamp(note.createdAt) && isTimestamp(note.updatedAt) && (note.deletedAt == null || isTimestamp(note.deletedAt)); }
function toResponseNote(row) { return { ...JSON.parse(row.payload), deletedAt: row.deleted_at }; }
