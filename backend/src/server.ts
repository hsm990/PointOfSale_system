import "dotenv/config";

import app from "./app";
import prisma from "./config/prisma";

const PORT = process.env.PORT || 4000;

async function main() {
  await prisma.$connect();
  console.log("Connected to database");

  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
}

main().catch((err) => {
  console.error("Failed to start server:", err);
  process.exit(1);
});
