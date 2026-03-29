import { Request, Response, NextFunction } from "express";
import { validationResult } from "express-validator";
import { todoService } from "../services/todo.service.js";
import type { CreateTodoDto, UpdateTodoDto } from "../types/todo.js";

interface IdParams {
  id: string;
}

export class TodoController {
  async getAll(_req: Request, res: Response, next: NextFunction) {
    try {
      const todos = await todoService.findAll();
      res.json({
        success: true,
        data: todos,
        count: todos.length,
      });
    } catch (error) {
      next(error);
    }
  }

  async getById(req: Request<IdParams>, res: Response, next: NextFunction) {
    try {
      const id = parseInt(req.params.id);
      
      if (isNaN(id)) {
        res.status(400).json({
          success: false,
          error: "ID inválido",
        });
        return;
      }

      const todo = await todoService.findById(id);
      
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
    } catch (error) {
      next(error);
    }
  }

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        res.status(400).json({
          success: false,
          errors: errors.array(),
        });
        return;
      }

      const data: CreateTodoDto = {
        title: req.body.title,
        description: req.body.description,
      };

      const todo = await todoService.create(data);

      res.status(201).json({
        success: true,
        data: todo,
        message: "Tarea creada exitosamente",
      });
    } catch (error) {
      next(error);
    }
  }

  async update(req: Request<IdParams>, res: Response, next: NextFunction) {
    try {
      const id = parseInt(req.params.id);
      
      if (isNaN(id)) {
        res.status(400).json({
          success: false,
          error: "ID inválido",
        });
        return;
      }

      const existingTodo = await todoService.findById(id);
      if (!existingTodo) {
        res.status(404).json({
          success: false,
          error: "Tarea no encontrada",
        });
        return;
      }

      const data: UpdateTodoDto = {
        title: req.body.title,
        description: req.body.description,
        completed: req.body.completed,
      };

      const todo = await todoService.update(id, data);

      res.json({
        success: true,
        data: todo,
        message: "Tarea actualizada exitosamente",
      });
    } catch (error) {
      next(error);
    }
  }

  async delete(req: Request<IdParams>, res: Response, next: NextFunction) {
    try {
      const id = parseInt(req.params.id);
      
      if (isNaN(id)) {
        res.status(400).json({
          success: false,
          error: "ID inválido",
        });
        return;
      }

      const existingTodo = await todoService.findById(id);
      if (!existingTodo) {
        res.status(404).json({
          success: false,
          error: "Tarea no encontrada",
        });
        return;
      }

      await todoService.delete(id);

      res.json({
        success: true,
        message: "Tarea eliminada exitosamente",
      });
    } catch (error) {
      next(error);
    }
  }

  async toggleComplete(req: Request<IdParams>, res: Response, next: NextFunction) {
    try {
      const id = parseInt(req.params.id);
      
      if (isNaN(id)) {
        res.status(400).json({
          success: false,
          error: "ID inválido",
        });
        return;
      }

      const todo = await todoService.toggleComplete(id);
      
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
    } catch (error) {
      next(error);
    }
  }
}

export const todoController = new TodoController();
