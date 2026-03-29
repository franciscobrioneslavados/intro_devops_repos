import { Request, Response, NextFunction } from "express";
export interface ApiError extends Error {
    statusCode?: number;
    message: string;
}
export declare function errorHandler(err: ApiError, _req: Request, res: Response, _next: NextFunction): void;
export declare function notFoundHandler(_req: Request, res: Response): void;
//# sourceMappingURL=error.middleware.d.ts.map