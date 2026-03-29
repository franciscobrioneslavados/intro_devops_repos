"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = errorHandler;
exports.notFoundHandler = notFoundHandler;
function errorHandler(err, _req, res, _next) {
    console.error("Error:", err.message);
    const statusCode = err.statusCode || 500;
    const message = statusCode === 500 ? "Error interno del servidor" : err.message;
    res.status(statusCode).json({
        success: false,
        error: message,
        ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
    });
}
function notFoundHandler(_req, res) {
    res.status(404).json({
        success: false,
        error: "Ruta no encontrada",
    });
}
//# sourceMappingURL=error.middleware.js.map