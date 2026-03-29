import { Request, Response, NextFunction } from "express";

export interface ApiError extends Error {
  statusCode?: number;
  message: string;
}

export function errorHandler(
  err: ApiError,
  _req: Request,
  res: Response,
  _next: NextFunction
) {
  console.error("Error:", err.message);

  const statusCode = err.statusCode || 500;
  const message = statusCode === 500 ? "Error interno del servidor" : err.message;

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  });
}

export function notFoundHandler(_req: Request, res: Response) {
  res.status(404).json({
    success: false,
    error: "Ruta no encontrada",
  });
}
