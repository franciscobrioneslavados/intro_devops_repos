"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
require("dotenv/config");
const todo_routes_js_1 = __importDefault(require("./routes/todo.routes.js"));
const error_middleware_js_1 = require("./middleware/error.middleware.js");
const database_js_1 = __importDefault(require("./config/database.js"));
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
app.use((0, cors_1.default)());
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
app.get("/health", (_req, res) => {
    res.json({
        status: "OK",
        timestamp: new Date().toISOString(),
        service: "actividad4-backend",
    });
});
app.use("/api/todos", todo_routes_js_1.default);
app.use(error_middleware_js_1.notFoundHandler);
app.use(error_middleware_js_1.errorHandler);
async function main() {
    try {
        await database_js_1.default.$connect();
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
    }
    catch (error) {
        console.error("❌ Error al conectar con la base de datos:", error);
        process.exit(1);
    }
}
main();
process.on("SIGINT", async () => {
    await database_js_1.default.$disconnect();
    console.log("\n👋 Conexión cerrada");
    process.exit(0);
});
//# sourceMappingURL=index.js.map