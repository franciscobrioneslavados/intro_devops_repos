const express = require('express');

const app = express();
const port = process.env.PORT || 3000;

const toNumber = (value) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
};

app.get('/', (req, res) => {
  res.send('Hola desde Express y Docker/Podman!');
});

app.get('/sum', (req, res) => {
  const a = toNumber(req.query.a);
  const b = toNumber(req.query.b);
  res.json({ result: a + b });
});

app.get('/subtract', (req, res) => {
  const a = toNumber(req.query.a);
  const b = toNumber(req.query.b);
  res.json({ result: a - b });
});

if (require.main === module) {
  app.listen(port, () => console.log(`Escuchando en ${port}`));
}

module.exports = app;
