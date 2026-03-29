import { Router, Request, Response, NextFunction } from "express";
import { body } from "express-validator";
import { todoController } from "../controllers/todo.controller.js";

const router = Router();

router.get("/", (req: Request, res: Response, next: NextFunction) => 
  todoController.getAll(req, res, next)
);

router.get("/:id", (req: Request, res: Response, next: NextFunction) => 
  todoController.getById(req as any, res, next)
);

router.post(
  "/",
  [
    body("title")
      .notEmpty()
      .withMessage("El título es requerido")
      .isLength({ max: 255 })
      .withMessage("El título no puede exceder 255 caracteres"),
    body("description")
      .optional()
      .isString()
      .withMessage("La descripción debe ser un texto"),
  ],
  (req: Request, res: Response, next: NextFunction) => 
    todoController.create(req, res, next)
);

router.put(
  "/:id",
  [
    body("title")
      .optional()
      .isLength({ min: 1, max: 255 })
      .withMessage("El título debe tener entre 1 y 255 caracteres"),
    body("description")
      .optional()
      .isString()
      .withMessage("La descripción debe ser un texto"),
    body("completed")
      .optional()
      .isBoolean()
      .withMessage("Completed debe ser un booleano"),
  ],
  (req: Request, res: Response, next: NextFunction) => 
    todoController.update(req as any, res, next)
);

router.delete("/:id", (req: Request, res: Response, next: NextFunction) => 
  todoController.delete(req as any, res, next)
);

router.patch("/:id/toggle", (req: Request, res: Response, next: NextFunction) => 
  todoController.toggleComplete(req as any, res, next)
);

export default router;
