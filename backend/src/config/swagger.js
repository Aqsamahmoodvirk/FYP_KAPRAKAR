const swaggerJsdoc = require("swagger-jsdoc");

const options = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "KapraKar API Documentation",
      version: "1.0.0",
      description:
        "API documentation for KapraKar - The Tailor in Your Pocket. A smart tailoring platform for custom stitching services.",
      contact: {
        name: "KapraKar Team (F25CS189)",
        email: "kaprakar@ucp.edu.pk",
      },
    },
    servers: [
      {
        url: "http://localhost:5000",
        description: "Development server",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
          description: "Enter Firebase ID token (from Flutter app)",
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  // Paths to files that contain Swagger annotations
  apis: ["./src/routes/*.js"],
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;