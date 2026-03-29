#!/bin/sh
set -e

echo "🔄 Sincronizando base de datos..."
npx prisma db push --skip-generate

echo "✅ Base de datos lista!"
echo "🚀 Iniciando servidor..."

exec node dist/index.js
