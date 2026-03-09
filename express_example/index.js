const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hola desde Express y Docker/Podman!');
});

app.listen(port, () => console.log(`Escuchando en ${port}`));
