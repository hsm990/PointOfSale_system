// prisma/seed.ts

import "dotenv/config";

import { PrismaClient, UserRole } from "../src/generated/prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";
import bcrypt from "bcryptjs";

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!,
});

const prisma = new PrismaClient({
  adapter,
});

async function main() {
  console.log("🌱 Seeding database...");

  const restaurant = await prisma.restaurant.upsert({
    where: {
      id: "main-restaurant",
    },
    update: {},
    create: {
      id: "main-restaurant",
      name: "My Restaurant",
      address: "Algeria",
      phone: "+213000000000",
    },
  });

  // =========================
  // Super Admin
  // =========================

  const passwordHash = await bcrypt.hash(process.env.SEED_ADMIN_PASSWORD!, 10);

  const admin = await prisma.user.upsert({
    where: {
      email: "admin@restaurant.com",
    },
    update: {},
    create: {
      email: process.env.SEED_ADMIN_EMAIL!,
      passwordHash,
      firstName: "Super",
      lastName: "Admin",
      role: UserRole.SUPER_ADMIN,
      restaurantId: restaurant.id,
    },
  });

  // =========================
  // Categories
  // =========================

  const pizzaCategory = await prisma.category.create({
    data: {
      name: "Pizza",
      restaurantId: restaurant.id,
      sortOrder: 1,
    },
  });

  const drinksCategory = await prisma.category.create({
    data: {
      name: "Drinks",
      restaurantId: restaurant.id,
      sortOrder: 2,
    },
  });

  const dessertsCategory = await prisma.category.create({
    data: {
      name: "Desserts",
      restaurantId: restaurant.id,
      sortOrder: 3,
    },
  });

  // =========================
  // Products
  // =========================

  await prisma.product.createMany({
    data: [
      {
        name: "Margherita Pizza",
        description: "Classic pizza with mozzarella",
        price: 12,
        cost: 5,
        categoryId: pizzaCategory.id,
        restaurantId: restaurant.id,
      },
      {
        name: "Pepperoni Pizza",
        description: "Pepperoni & cheese",
        price: 15,
        cost: 7,
        categoryId: pizzaCategory.id,
        restaurantId: restaurant.id,
      },
      {
        name: "Coca Cola",
        price: 2,
        cost: 1,
        categoryId: drinksCategory.id,
        restaurantId: restaurant.id,
      },
      {
        name: "Water",
        price: 1,
        cost: 0.4,
        categoryId: drinksCategory.id,
        restaurantId: restaurant.id,
      },
      {
        name: "Chocolate Cake",
        price: 6,
        cost: 2.5,
        categoryId: dessertsCategory.id,
        restaurantId: restaurant.id,
      },
    ],
  });

  console.log("✅ Database seeded successfully!");
  console.log("--------------------------------");
  console.log("Restaurant :", restaurant.name);
  console.log("Admin Email:", admin.email);
  console.log("Password   : admin123");
  console.log("--------------------------------");
}

main()
  .catch((error) => {
    console.error("❌ Seed failed");
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
