import { Request, Response, NextFunction } from "express";
interface IdParams {
    id: string;
}
export declare class TodoController {
    getAll(_req: Request, res: Response, next: NextFunction): Promise<void>;
    getById(req: Request<IdParams>, res: Response, next: NextFunction): Promise<void>;
    create(req: Request, res: Response, next: NextFunction): Promise<void>;
    update(req: Request<IdParams>, res: Response, next: NextFunction): Promise<void>;
    delete(req: Request<IdParams>, res: Response, next: NextFunction): Promise<void>;
    toggleComplete(req: Request<IdParams>, res: Response, next: NextFunction): Promise<void>;
}
export declare const todoController: TodoController;
export {};
//# sourceMappingURL=todo.controller.d.ts.map