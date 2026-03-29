const jwt = require("jsonwebtoken");

const generateToken = (id) => {
  // This signs a new token using a secret key and sets it to expire in 30 days
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: "30d",
  });
};

module.exports = generateToken;
