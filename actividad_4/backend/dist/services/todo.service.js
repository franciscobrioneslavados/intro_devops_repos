"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.todoService = exports.TodoService = void 0;
const database_js_1 = __importDefault(require("../config/database.js"));
class TodoService {
    async findAll() {
        return database_js_1.default.todo.findMany({
            orderBy: { createdAt: "desc" },
        });
    }
    async findById(id) {
        return database_js_1.default.todo.findUnique({
            where: { id },
        });
    }
    async create(data) {
        return database_js_1.default.todo.create({
            data: {
                title: data.title,
                description: data.description || null,
            },
        });
    }
    async update(id, data) {
        return database_js_1.default.todo.update({
            where: { id },
            data,
        });
    }
    async delete(id) {
        return database_js_1.default.todo.delete({
            where: { id },
        });
    }
    async toggleComplete(id) {
        const todo = await this.findById(id);
        if (!todo)
            return null;
        return database_js_1.default.todo.update({
            where: { id },
            data: {
                completed: !todo.completed,
            },
        });
    }
}
exports.TodoService = TodoService;
exports.todoService = new TodoService();
//# sourceMappingURL=todo.service.js.map