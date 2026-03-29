import { Request } from "express";
export interface Todo {
    id: number;
    title: string;
    description: string | null;
    completed: boolean;
    createdAt: Date;
    updatedAt: Date;
}
export interface CreateTodoDto {
    title: string;
    description?: string;
}
export interface UpdateTodoDto {
    title?: string;
    description?: string;
    completed?: boolean;
}
export interface AuthenticatedRequest extends Request {
    user?: {
        id: string;
    };
}
//# sourceMappingURL=todo.d.ts.map