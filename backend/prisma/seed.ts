//seed.js
require("dotenv").config(); // add this if seed.js is run standalone (not through server.js)

const { PrismaClient } = require("../generated/prisma/client"); // adjust path based on seed.js's actual location
const { PrismaPg } = require("@prisma/adapter-pg");
const bcrypt = require("bcryptjs");

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

async function main() {
  const branch = await prisma.branch.upsert({
    where: { code: "HQ" },
    update: {},
    create: {
      name: "Main Branch",
      code: "HQ",
      address: "123 Main Street",
      phone: "+1-555-0100",
    },
  });

  const passwordHash = await bcrypt.hash("admin123", 10);

  const admin = await prisma.user.upsert({
    where: { email: "admin@restaurant.local" },
    update: {},
    create: {
      email: "admin@restaurant.local",
      passwordHash,
      firstName: "Admin",
      lastName: "User",
      branchRoles: {
        create: {
          branchId: branch.id,
          role: "ADMIN",
        },
      },
    },
  });

  console.log("Seed completed:", { branch: branch.name, admin: admin.email });
}

main()
  .catch((e) => {
    console.error("Seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
