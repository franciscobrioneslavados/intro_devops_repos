const assert = require('node:assert');
const app = require('./index');

const req = {
  method: 'GET',
  url: '/',
  headers: {},
  socket: {},
};

const res = {
  statusCode: 200,
  body: '',
  headers: {},
  status(code) {
    this.statusCode = code;
    return this;
  },
  set(header, value) {
    this.headers[header] = value;
    return this;
  },
  setHeader(header, value) {
    this.headers[header.toLowerCase()] = value;
    return this;
  },
  getHeader(header) {
    return this.headers[header.toLowerCase()];
  },
  getHeaders() {
    return this.headers;
  },
  send(payload) {
    this.body = typeof payload === 'string' ? payload : JSON.stringify(payload);
    return this;
  },
  end() {
    return this;
  },
  json(payload) {
    this.body = JSON.stringify(payload);
    return this;
  },
};

app.handle(req, res, (err) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  try {
    assert.strictEqual(res.statusCode, 200, 'status code');
    assert.ok(res.body.includes('Hola desde Express'), 'greeting present');
    console.log('Express test passed');
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
});
