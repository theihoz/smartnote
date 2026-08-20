import { createApiSimulator } from './simulator.js';

const sampleNote = {
  id: '22222222-2222-4222-8222-222222222222',
  title: 'Ý tưởng cho SmartNote',
  body: 'Xây dựng trải nghiệm ghi chú offline-first.',
  kind: 'text',
  checklist: [],
  tags: ['API', 'Demo'],
  imagePaths: [],
  isFavorite: true,
  isLocked: false,
  colorKey: 'lavender',
  createdAt: '2026-08-20T08:00:00.000Z',
  updatedAt: '2026-08-20T08:00:00.000Z',
  deletedAt: null,
};

const endpoints = [
  { name: 'Health', method: 'GET', path: '/health', device: false },
  { name: 'List notes', method: 'GET', path: '/v1/notes', device: true },
  { name: 'Get note', method: 'GET', path: '/v1/notes/{noteId}', device: true },
  { name: 'Upsert note', method: 'PUT', path: '/v1/notes/{noteId}', device: true, body: sampleNote },
  { name: 'Delete note', method: 'DELETE', path: '/v1/notes/{noteId}', device: true },
  { name: 'Random quote', method: 'GET', path: '/v1/quotes/random', device: false },
];

const simulator = createApiSimulator();
const $ = (selector) => document.querySelector(selector);
let selected = 0;
let mode = 'mock';

function resolvedPath(endpoint) {
  return endpoint.path.replace('{noteId}', $('#note-id').value.trim());
}

function renderEndpoints() {
  $('#endpoint-list').innerHTML = endpoints.map((endpoint, index) => `
    <button class="endpoint ${index === selected ? 'active' : ''}" data-index="${index}" type="button">
      <span class="mini-method ${endpoint.method.toLowerCase()}">${endpoint.method}</span>
      <span>${endpoint.name}<br><small>${endpoint.path}</small></span>
    </button>`).join('');
}

function renderRequest() {
  const endpoint = endpoints[selected];
  const path = resolvedPath(endpoint);
  $('#method').textContent = endpoint.method;
  $('#method').className = `method ${endpoint.method.toLowerCase()}`;
  $('#path').textContent = path;
  $('#request-url').textContent = `${$('#base-url').value.replace(/\/$/, '')}${path}`;
  const headers = $('#headers');
  headers.replaceChildren(...[
    ['Content-Type', 'application/json'],
    ...(endpoint.device ? [['X-Device-Id', $('#device-id').value.trim()]] : []),
  ].map(([key, value]) => {
    const row = document.createElement('div');
    row.className = 'header-row';
    for (const text of [key, value]) {
      const cell = document.createElement('span');
      cell.textContent = text;
      row.append(cell);
    }
    return row;
  }));
  $('#body-label').hidden = !endpoint.body;
  if (endpoint.body && !$('#request-body').value) {
    $('#request-body').value = JSON.stringify({ ...endpoint.body, id: $('#note-id').value.trim() }, null, 2);
  }
}

async function runRequest() {
  const endpoint = endpoints[selected];
  const path = resolvedPath(endpoint);
  let body;
  try {
    body = endpoint.body ? JSON.parse($('#request-body').value) : undefined;
  } catch {
    showResponse(0, { error: { code: 'INVALID_JSON', message: 'Request body must be valid JSON.' } }, 0);
    return;
  }

  $('#run').disabled = true;
  $('#run').textContent = 'Đang gửi…';
  const started = performance.now();
  try {
    if (mode === 'mock') {
      await new Promise((resolve) => setTimeout(resolve, 180));
      const result = simulator.request({ method: endpoint.method, path, deviceId: $('#device-id').value.trim(), body });
      showResponse(result.status, result.body, performance.now() - started);
    } else {
      const response = await fetch(`${$('#base-url').value.replace(/\/$/, '')}${path}`, {
        method: endpoint.method,
        headers: {
          'content-type': 'application/json',
          ...(endpoint.device ? { 'x-device-id': $('#device-id').value.trim() } : {}),
        },
        body: body ? JSON.stringify(body) : undefined,
      });
      const responseBody = await response.json();
      showResponse(response.status, responseBody, performance.now() - started);
    }
  } catch (error) {
    showResponse(0, { error: { code: 'NETWORK_ERROR', message: error.message, hint: 'Kiểm tra API URL, HTTPS và cấu hình CORS.' } }, performance.now() - started);
  } finally {
    $('#run').disabled = false;
    $('#run').innerHTML = '<span>▶</span> Gửi request';
  }
}

function showResponse(status, body, duration = 0) {
  const text = JSON.stringify(body, null, 2);
  $('#status').textContent = status ? `${status} ${status < 400 ? 'OK' : 'ERROR'}` : 'NETWORK ERROR';
  $('#status').className = `status ${status && status < 400 ? 'success' : 'error'}`;
  $('#duration').textContent = `${Math.round(duration)} ms`;
  $('#size').textContent = `${new Blob([text]).size} B`;
  $('#response').textContent = text;
}

function setMode(nextMode) {
  mode = nextMode;
  document.querySelectorAll('.mode').forEach((button) => button.classList.toggle('active', button.dataset.mode === mode));
  $('#mode-label').textContent = mode === 'mock' ? 'Simulation ready' : 'Live API enabled';
  $('#mode-help').textContent = mode === 'mock' ? 'Dữ liệu chỉ tồn tại trong tab này.' : 'Yêu cầu HTTPS/CORS khi chạy từ Pages.';
}

document.addEventListener('click', async (event) => {
  const endpoint = event.target.closest('.endpoint');
  if (endpoint) {
    selected = Number(endpoint.dataset.index);
    $('#request-body').value = '';
    renderEndpoints();
    renderRequest();
  }
  const modeButton = event.target.closest('.mode');
  if (modeButton) setMode(modeButton.dataset.mode);
  if (event.target.closest('#run')) await runRequest();
  const copy = event.target.closest('[data-copy]');
  if (copy) {
    const text = copy.dataset.copy === 'response' ? $('#response').textContent : `${$('#method').textContent} ${$('#request-url').textContent}`;
    await navigator.clipboard.writeText(text);
    copy.textContent = 'Đã chép';
    setTimeout(() => { copy.textContent = 'Sao chép'; }, 1200);
  }
});

['base-url', 'device-id', 'note-id'].forEach((id) => $(`#${id}`).addEventListener('input', renderRequest));
renderEndpoints();
renderRequest();
runRequest();
