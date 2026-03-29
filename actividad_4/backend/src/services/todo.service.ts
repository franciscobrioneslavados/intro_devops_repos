import prisma from "../config/database.js";
import type { CreateTodoDto, UpdateTodoDto } from "../types/todo.js";
import type { Todo } from "@prisma/client";

export class TodoService {
  async findAll(): Promise<Todo[]> {
    return prisma.todo.findMany({
      orderBy: { createdAt: "desc" },
    });
  }

  async findById(id: number): Promise<Todo | null> {
    return prisma.todo.findUnique({
      where: { id },
    });
  }

  async create(data: CreateTodoDto): Promise<Todo> {
    return prisma.todo.create({
      data: {
        title: data.title,
        description: data.description || null,
      },
    });
  }

  async update(id: number, data: UpdateTodoDto): Promise<Todo | null> {
    return prisma.todo.update({
      where: { id },
      data,
    });
  }

  async delete(id: number): Promise<Todo | null> {
    return prisma.todo.delete({
      where: { id },
    });
  }

  async toggleComplete(id: number): Promise<Todo | null> {
    const todo = await this.findById(id);
    if (!todo) return null;

    return prisma.todo.update({
      where: { id },
      data: {
        completed: !todo.completed,
      },
    });
  }
}

export const todoService = new TodoService();
