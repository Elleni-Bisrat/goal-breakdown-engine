import { protect } from "../middleware/auth.middleware.js";
const router = express.Router();
router.get("/:foalId", protect, getGoalProgress);
router.get("/dashboard/summary", protect, getDashboeard);

export default router;