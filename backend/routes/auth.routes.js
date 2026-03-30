import express from "express";
import { signUp, signIn, logout } from "../controllers/auth.controller.js";

const authRoutes = express.Router();

authRoutes.post("/signup", signUp);
authRoutes.post("/login", signIn);
authRoutes.post('/logout', logout);


export default authRoutes;
