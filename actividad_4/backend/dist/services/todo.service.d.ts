import type { CreateTodoDto, UpdateTodoDto } from "../types/todo.js";
import type { Todo } from "@prisma/client";
export declare class TodoService {
    findAll(): Promise<Todo[]>;
    findById(id: number): Promise<Todo | null>;
    create(data: CreateTodoDto): Promise<Todo>;
    update(id: number, data: UpdateTodoDto): Promise<Todo | null>;
    delete(id: number): Promise<Todo | null>;
    toggleComplete(id: number): Promise<Todo | null>;
}
export declare const todoService: TodoService;
//# sourceMappingURL=todo.service.d.ts.map