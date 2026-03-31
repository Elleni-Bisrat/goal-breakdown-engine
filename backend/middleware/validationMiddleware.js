export const validateSignup = (req, res, next) => {
    const { username, email, password, confirmPassword } = req.body;

    if (!email || !username || !password || !confirmPassword) {
        res.status(400);
        throw new Error("All fields are required");
    }

   if (username.trim().length < 3) {
     res.status(400);
     throw new Error("Username must be at least 3 characters");
         }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        res.status(400);
        throw new Error("Invalid email format");
    }

    if (password.length < 6) {
        res.status(400);
        throw new Error("Password must be at least 6 characters");
    }

    const strongPasswordRegex = /^(?=.*[A-Za-z])(?=.*\d)/;
    if (!strongPasswordRegex.test(password)) {
        res.status(400);
        throw new Error("Password must contain letters and numbers");
    }
    
    if (password !== confirmPassword) {
    res.status(400);
    throw new Error("Passwords do not match");
    }

    next();
};

export const validateLogin = (req, res, next) => {
    const { email, password } = req.body;

    if (!email || !password) {
        res.status(400);
        throw new Error("Email and password are required");
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        res.status(400);
        throw new Error("Invalid email format");
    }

    next();
};

export const validateGoal = (req, res, next) => {
    const { title, duration } = req.body;

    if (!title || title.trim() === "") {
        res.status(400);
        throw new Error("Goal title is required");
    }

    if (duration === undefined) {
        res.status(400);
        throw new Error("Duration is required");
    } 

    if (typeof duration !== "number") {
        res.status(400);
        throw new Error("Duration must be a number");
    }

    if (duration <= 0) {
        res.status(400);
        throw new Error("Duration must be greater than 0");
    }

    next();
};