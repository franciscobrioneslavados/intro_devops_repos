const assert = require('node:assert');
const app = require('./index');

const baseReq = {
  method: 'GET',
  headers: {},
  socket: {},
};

const createRes = () => {
  return {
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
};

const cases = [
  {
    description: 'root greeting',
    url: '/',
    assert: (res) => {
      assert.strictEqual(res.statusCode, 200, 'status code should be 200');
      assert.ok(res.body.includes('Hola desde Express'), 'greeting text');
    },
  },
  {
    description: 'sum endpoint returns addition',
    url: '/sum?a=5&b=3',
    assert: (res) => {
      const payload = JSON.parse(res.body);
      assert.strictEqual(payload.result, 8);
    },
  },
  {
    description: 'subtract endpoint returns difference',
    url: '/subtract?a=10&b=6',
    assert: (res) => {
      const payload = JSON.parse(res.body);
      assert.strictEqual(payload.result, 4);
    },
  },
];

const runCase = (index) => {
  if (index >= cases.length) {
    console.log('Express test passed');
    process.exit(0);
  }
  const testCase = cases[index];
  const req = { ...baseReq, url: testCase.url };
  const res = createRes();

  app.handle(req, res, (err) => {
    if (err) {
      console.error(err);
      process.exit(1);
      return;
    }
    try {
      testCase.assert(res);
      runCase(index + 1);
    } catch (error) {
      console.error(testCase.description, error);
      process.exit(1);
    }
  });
};

runCase(0);
