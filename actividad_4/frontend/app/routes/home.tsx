import type { Route } from "./+types/home";
import { TodoApp } from "../components/TodoApp";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "TODO App - Actividad 4" },
    { name: "description", content: "Aplicación de tareas con Material UI" },
  ];
}

export default function Home() {
  return <TodoApp />;
}
