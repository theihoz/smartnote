import { mkdirSync } from 'node:fs';

import { createApp } from './app.js';

mkdirSync('api/data', { recursive: true });
const port = Number(process.env.PORT || 8787);
createApp().listen(port, () => console.log(JSON.stringify({ event: 'server_started', port })));
