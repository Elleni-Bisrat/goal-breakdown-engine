import "./env.js";
import mongoose from "mongoose";
import { DB_URI } from "./env.js";
const connectDB = async () => {
  try {
    await mongoose.connect(DB_URI);
    console.log("Database connected successfully");
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
};
export  default connectDB;