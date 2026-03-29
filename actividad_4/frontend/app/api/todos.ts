// API_URL is left empty so requests use the same origin (handled by Nginx proxy)
const API_URL = "";

export interface Todo {
  id: number;
  title: string;
  description: string | null;
  completed: boolean;
  createdAt: string;
  updatedAt: string;
}

export const todoApi = {
  getAll: async (): Promise<Todo[]> => {
    const response = await fetch(`${API_URL}/api/todos`);
    if (!response.ok) throw new Error("Error fetching todos");
    const result = await response.json();
    return result.data;
  },

  getById: async (id: number): Promise<Todo> => {
    const response = await fetch(`${API_URL}/api/todos/${id}`);
    if (!response.ok) throw new Error("Error fetching todo");
    const result = await response.json();
    return result.data;
  },

  create: async (title: string, description?: string): Promise<Todo> => {
    const response = await fetch(`${API_URL}/api/todos`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title, description }),
    });
    if (!response.ok) throw new Error("Error creating todo");
    const result = await response.json();
    return result.data;
  },

  update: async (
    id: number,
    data: Partial<{ title: string; description: string; completed: boolean }>,
  ): Promise<Todo> => {
    const response = await fetch(`${API_URL}/api/todos/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });
    if (!response.ok) throw new Error("Error updating todo");
    const result = await response.json();
    return result.data;
  },

  delete: async (id: number): Promise<void> => {
    const response = await fetch(`${API_URL}/api/todos/${id}`, {
      method: "DELETE",
    });
    if (!response.ok) throw new Error("Error deleting todo");
  },

  toggle: async (id: number): Promise<Todo> => {
    const response = await fetch(`${API_URL}/api/todos/${id}/toggle`, {
      method: "PATCH",
    });
    if (!response.ok) throw new Error("Error toggling todo");
    const result = await response.json();
    return result.data;
  },
};
