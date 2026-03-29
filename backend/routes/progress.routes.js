import express from 'express';
import { protect } from '../middleware/auth.middleware.js';
import { getGoalProgress, getDashboardProgress } from '../controllers/progress.controller.js'

const progressRoutes = express.Router();

progressRoutes.use(protect);

progressRoutes.get('/dashboard', getDashboardProgress);
progressRoutes.get('/:goalId', getGoalProgress);

export default progressRoutes;