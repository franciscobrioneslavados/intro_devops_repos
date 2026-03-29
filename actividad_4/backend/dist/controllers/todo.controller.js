"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.todoController = exports.TodoController = void 0;
const express_validator_1 = require("express-validator");
const todo_service_js_1 = require("../services/todo.service.js");
class TodoController {
    async getAll(_req, res, next) {
        try {
            const todos = await todo_service_js_1.todoService.findAll();
            res.json({
                success: true,
                data: todos,
                count: todos.length,
            });
        }
        catch (error) {
            next(error);
        }
    }
    async getById(req, res, next) {
        try {
            const id = parseInt(req.params.id);
            if (isNaN(id)) {
                res.status(400).json({
                    success: false,
                    error: "ID inválido",
                });
                return;
            }
            const todo = await todo_service_js_1.todoService.findById(id);
            if (!todo) {
                res.status(404).json({
                    success: false,
                    error: "Tarea no encontrada",
                });
                return;
            }
            res.json({
                success: true,
                data: todo,
            });
        }
        catch (error) {
            next(error);
        }
    }
    async create(req, res, next) {
        try {
            const errors = (0, express_validator_1.validationResult)(req);
            if (!errors.isEmpty()) {
                res.status(400).json({
                    success: false,
                    errors: errors.array(),
                });
                return;
            }
            const data = {
                title: req.body.title,
                description: req.body.description,
            };
            const todo = await todo_service_js_1.todoService.create(data);
            res.status(201).json({
                success: true,
                data: todo,
                message: "Tarea creada exitosamente",
            });
        }
        catch (error) {
            next(error);
        }
    }
    async update(req, res, next) {
        try {
            const id = parseInt(req.params.id);
            if (isNaN(id)) {
                res.status(400).json({
                    success: false,
                    error: "ID inválido",
                });
                return;
            }
            const existingTodo = await todo_service_js_1.todoService.findById(id);
            if (!existingTodo) {
                res.status(404).json({
                    success: false,
                    error: "Tarea no encontrada",
                });
                return;
            }
            const data = {
                title: req.body.title,
                description: req.body.description,
                completed: req.body.completed,
            };
            const todo = await todo_service_js_1.todoService.update(id, data);
            res.json({
                success: true,
                data: todo,
                message: "Tarea actualizada exitosamente",
            });
        }
        catch (error) {
            next(error);
        }
    }
    async delete(req, res, next) {
        try {
            const id = parseInt(req.params.id);
            if (isNaN(id)) {
                res.status(400).json({
                    success: false,
                    error: "ID inválido",
                });
                return;
            }
            const existingTodo = await todo_service_js_1.todoService.findById(id);
            if (!existingTodo) {
                res.status(404).json({
                    success: false,
                    error: "Tarea no encontrada",
                });
                return;
            }
            await todo_service_js_1.todoService.delete(id);
            res.json({
                success: true,
                message: "Tarea eliminada exitosamente",
            });
        }
        catch (error) {
            next(error);
        }
    }
    async toggleComplete(req, res, next) {
        try {
            const id = parseInt(req.params.id);
            if (isNaN(id)) {
                res.status(400).json({
                    success: false,
                    error: "ID inválido",
                });
                return;
            }
            const todo = await todo_service_js_1.todoService.toggleComplete(id);
            if (!todo) {
                res.status(404).json({
                    success: false,
                    error: "Tarea no encontrada",
                });
                return;
            }
            res.json({
                success: true,
                data: todo,
                message: `Tarea marcada como ${todo.completed ? "completada" : "pendiente"}`,
            });
        }
        catch (error) {
            next(error);
        }
    }
}
exports.TodoController = TodoController;
exports.todoController = new TodoController();
//# sourceMappingURL=todo.controller.js.map