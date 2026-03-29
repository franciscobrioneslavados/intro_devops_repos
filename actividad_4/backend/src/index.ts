import express from "express";
import cors from "cors";
import "dotenv/config";
import todoRoutes from "./routes/todo.routes.js";
import { errorHandler, notFoundHandler } from "./middleware/error.middleware.js";
import prisma from "./config/database.js";
import swaggerJsdoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const swaggerOptions = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "actividad4-backend API",
      version: "1.0.0",
      description: "REST API para TODO App con Swagger",
    },
    servers: [
      {
        url: `http://localhost:${PORT}`,
        description: "Development server",
      },
    ],
  },
  apis: ["./src/routes/*.ts"],
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.get("/health", (_req, res) => {
  res.json({
    status: "OK",
    timestamp: new Date().toISOString(),
    service: "actividad4-backend",
  });
});

app.use("/api/todos", todoRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

async function main() {
  try {
    await prisma.$connect();
    console.log("✅ Conexión a PostgreSQL establecida");

    app.listen(PORT, () => {
      console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
      console.log(`📋 Endpoints disponibles:`);
      console.log(`   GET    /api/todos`);
      console.log(`   GET    /api/todos/:id`);
      console.log(`   POST   /api/todos`);
      console.log(`   PUT    /api/todos/:id`);
      console.log(`   DELETE /api/todos/:id`);
      console.log(`   PATCH  /api/todos/:id/toggle`);
    });
  } catch (error) {
    console.error("❌ Error al conectar con la base de datos:", error);
    process.exit(1);
  }
}

main();

process.on("SIGINT", async () => {
  await prisma.$disconnect();
  console.log("\n👋 Conexión cerrada");
  process.exit(0);
});
