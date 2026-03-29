import express from "express";
import { signUp, signIn } from "../controllers/auth.controller.js";

const authRoutes = express.Router();

authRoutes.post("/signup", signUp);
authRoutes.post("/login", signIn);

export default authRoutes;
