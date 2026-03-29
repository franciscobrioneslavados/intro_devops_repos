import { useState, useEffect } from "react";
import {
  Container,
  Paper,
  Typography,
  TextField,
  Button,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  IconButton,
  Checkbox,
  Box,
  AppBar,
  Toolbar,
  Chip,
} from "@mui/material";
import DeleteIcon from "@mui/icons-material/Delete";
import EditIcon from "@mui/icons-material/Edit";
import { todoApi, Todo } from "../api/todos";

interface TodoUI extends Todo {
  editing?: boolean;
}

export function TodoApp() {
  const [todos, setTodos] = useState<TodoUI[]>([]);
  const [newTodo, setNewTodo] = useState("");
  const [editingText, setEditingText] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadTodos();
  }, []);

  const loadTodos = async () => {
    try {
      setLoading(true);
      const data = await todoApi.getAll();
      setTodos(data.map((t) => ({ ...t, editing: false })));
      setError(null);
    } catch (err) {
      setError("Error al cargar las tareas");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const addTodo = async () => {
    if (newTodo.trim() === "") return;

    try {
      const created = await todoApi.create(newTodo.trim());
      setTodos([...todos, { ...created, editing: false }]);
      setNewTodo("");
      setError(null);
    } catch (err) {
      setError("Error al crear la tarea");
      console.error(err);
    }
  };

  const toggleComplete = async (id: number) => {
    const todo = todos.find((t) => t.id === id);
    if (!todo) return;

    try {
      const updated = await todoApi.toggle(id);
      setTodos(todos.map((t) => (t.id === id ? { ...updated, editing: false } : t)));
      setError(null);
    } catch (err) {
      setError("Error al actualizar la tarea");
      console.error(err);
    }
  };

  const deleteTodo = async (id: number) => {
    try {
      await todoApi.delete(id);
      setTodos(todos.filter((todo) => todo.id !== id));
      setError(null);
    } catch (err) {
      setError("Error al eliminar la tarea");
      console.error(err);
    }
  };

  const startEditing = (id: number) => {
    const todo = todos.find((t) => t.id === id);
    if (todo) {
      setEditingText(todo.title);
      setTodos(
        todos.map((t) =>
          t.id === id ? { ...t, editing: true } : { ...t, editing: false }
        )
      );
    }
  };

  const saveEdit = async (id: number) => {
    if (editingText.trim() === "") return;

    try {
      const updated = await todoApi.update(id, { title: editingText.trim() });
      setTodos(todos.map((t) => (t.id === id ? { ...updated, editing: false } : t)));
      setEditingText("");
      setError(null);
    } catch (err) {
      setError("Error al guardar la tarea");
      console.error(err);
    }
  };

  const cancelEdit = () => {
    setTodos(todos.map((todo) => ({ ...todo, editing: false })));
    setEditingText("");
  };

  const completedCount = todos.filter((t) => t.completed).length;
  const pendingCount = todos.length - completedCount;

  if (loading) {
    return (
      <Box sx={{ minHeight: "100vh", bgcolor: "#f5f5f5", display: "flex", alignItems: "center", justifyContent: "center" }}>
        <Typography>Cargando...</Typography>
      </Box>
    );
  }

  return (
    <Box sx={{ minHeight: "100vh", bgcolor: "#f5f5f5", pb: 4 }}>
      <AppBar position="static" sx={{ mb: 4 }}>
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            TODO App - Actividad 4
          </Typography>
        </Toolbar>
      </AppBar>

      <Container maxWidth="md">
        <Paper elevation={3} sx={{ p: 3 }}>
          <Typography variant="h4" component="h1" gutterBottom align="center">
            Mis Tareas
          </Typography>

          {error && (
            <Chip label={error} color="error" sx={{ mb: 2, width: "100%" }} />
          )}

          <Box sx={{ display: "flex", gap: 2, mb: 3 }}>
            <TextField
              fullWidth
              variant="outlined"
              placeholder="Agregar nueva tarea..."
              value={newTodo}
              onChange={(e) => setNewTodo(e.target.value)}
              onKeyPress={(e) => e.key === "Enter" && addTodo()}
            />
            <Button
              variant="contained"
              color="primary"
              onClick={addTodo}
              sx={{ minWidth: 100 }}
            >
              Agregar
            </Button>
          </Box>

          <Box sx={{ mb: 2, display: "flex", gap: 1 }}>
            <Chip
              label={`Pendientes: ${pendingCount}`}
              color="warning"
              variant="outlined"
            />
            <Chip
              label={`Completadas: ${completedCount}`}
              color="success"
              variant="outlined"
            />
          </Box>

          <List>
            {todos.map((todo) => (
              <Paper
                key={todo.id}
                sx={{
                  mb: 1,
                  bgcolor: todo.completed ? "#e8f5e9" : "#ffffff",
                  transition: "background-color 0.3s",
                }}
              >
                <ListItem>
                  <Checkbox
                    checked={todo.completed}
                    onChange={() => toggleComplete(todo.id)}
                    color="primary"
                  />
                  
                  {todo.editing ? (
                    <Box sx={{ display: "flex", gap: 1, flexGrow: 1 }}>
                      <TextField
                        fullWidth
                        size="small"
                        value={editingText}
                        onChange={(e) => setEditingText(e.target.value)}
                        onKeyPress={(e) =>
                          e.key === "Enter" && saveEdit(todo.id)
                        }
                        autoFocus
                      />
                      <Button
                        size="small"
                        variant="contained"
                        onClick={() => saveEdit(todo.id)}
                      >
                        Guardar
                      </Button>
                      <Button size="small" onClick={cancelEdit}>
                        Cancelar
                      </Button>
                    </Box>
                  ) : (
                    <>
                      <ListItemText
                        primary={todo.title}
                        secondary={todo.description}
                        sx={{
                          textDecoration: todo.completed
                            ? "line-through"
                            : "none",
                          color: todo.completed ? "text.secondary" : "text.primary",
                        }}
                      />
                      <ListItemSecondaryAction>
                        <IconButton
                          edge="end"
                          aria-label="edit"
                          onClick={() => startEditing(todo.id)}
                          sx={{ color: "#1976d2" }}
                        >
                          <EditIcon />
                        </IconButton>
                        <IconButton
                          edge="end"
                          aria-label="delete"
                          onClick={() => deleteTodo(todo.id)}
                          sx={{ color: "#d32f2f" }}
                        >
                          <DeleteIcon />
                        </IconButton>
                      </ListItemSecondaryAction>
                    </>
                  )}
                </ListItem>
              </Paper>
            ))}
          </List>

          {todos.length === 0 && (
            <Typography
              variant="body1"
              align="center"
              color="text.secondary"
              sx={{ mt: 2 }}
            >
              No hay tareas. ¡Agrega una nueva!
            </Typography>
          )}
        </Paper>
      </Container>
    </Box>
  );
}
