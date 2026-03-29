"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const express_validator_1 = require("express-validator");
const todo_controller_js_1 = require("../controllers/todo.controller.js");
const router = (0, express_1.Router)();
router.get("/", (req, res, next) => todo_controller_js_1.todoController.getAll(req, res, next));
router.get("/:id", (req, res, next) => todo_controller_js_1.todoController.getById(req, res, next));
router.post("/", [
    (0, express_validator_1.body)("title")
        .notEmpty()
        .withMessage("El título es requerido")
        .isLength({ max: 255 })
        .withMessage("El título no puede exceder 255 caracteres"),
    (0, express_validator_1.body)("description")
        .optional()
        .isString()
        .withMessage("La descripción debe ser un texto"),
], (req, res, next) => todo_controller_js_1.todoController.create(req, res, next));
router.put("/:id", [
    (0, express_validator_1.body)("title")
        .optional()
        .isLength({ min: 1, max: 255 })
        .withMessage("El título debe tener entre 1 y 255 caracteres"),
    (0, express_validator_1.body)("description")
        .optional()
        .isString()
        .withMessage("La descripción debe ser un texto"),
    (0, express_validator_1.body)("completed")
        .optional()
        .isBoolean()
        .withMessage("Completed debe ser un booleano"),
], (req, res, next) => todo_controller_js_1.todoController.update(req, res, next));
router.delete("/:id", (req, res, next) => todo_controller_js_1.todoController.delete(req, res, next));
router.patch("/:id/toggle", (req, res, next) => todo_controller_js_1.todoController.toggleComplete(req, res, next));
exports.default = router;
//# sourceMappingURL=todo.routes.js.map