/*
  Warnings:

  - You are about to drop the column `branchId` on the `Category` table. All the data in the column will be lost.
  - You are about to drop the column `branchId` on the `Order` table. All the data in the column will be lost.
  - You are about to drop the column `branchId` on the `Product` table. All the data in the column will be lost.
  - You are about to drop the `Branch` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Modifier` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ModifierGroup` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `OrderItemModifier` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Payment` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ProductModifierGroup` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `UserBranch` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[restaurantId,orderNumber]` on the table `Order` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `restaurantId` to the `Category` table without a default value. This is not possible if the table is not empty.
  - Added the required column `restaurantId` to the `Order` table without a default value. This is not possible if the table is not empty.
  - Added the required column `restaurantId` to the `Product` table without a default value. This is not possible if the table is not empty.

*/
-- AlterEnum
ALTER TYPE "UserRole" ADD VALUE 'SUPER_ADMIN';

-- DropForeignKey
ALTER TABLE "Category" DROP CONSTRAINT "Category_branchId_fkey";

-- DropForeignKey
ALTER TABLE "Modifier" DROP CONSTRAINT "Modifier_modifierGroupId_fkey";

-- DropForeignKey
ALTER TABLE "Order" DROP CONSTRAINT "Order_branchId_fkey";

-- DropForeignKey
ALTER TABLE "OrderItemModifier" DROP CONSTRAINT "OrderItemModifier_modifierId_fkey";

-- DropForeignKey
ALTER TABLE "OrderItemModifier" DROP CONSTRAINT "OrderItemModifier_orderItemId_fkey";

-- DropForeignKey
ALTER TABLE "Payment" DROP CONSTRAINT "Payment_orderId_fkey";

-- DropForeignKey
ALTER TABLE "Product" DROP CONSTRAINT "Product_branchId_fkey";

-- DropForeignKey
ALTER TABLE "ProductModifierGroup" DROP CONSTRAINT "ProductModifierGroup_modifierGroupId_fkey";

-- DropForeignKey
ALTER TABLE "ProductModifierGroup" DROP CONSTRAINT "ProductModifierGroup_productId_fkey";

-- DropForeignKey
ALTER TABLE "UserBranch" DROP CONSTRAINT "UserBranch_branchId_fkey";

-- DropForeignKey
ALTER TABLE "UserBranch" DROP CONSTRAINT "UserBranch_userId_fkey";

-- AlterTable
ALTER TABLE "Category" DROP COLUMN "branchId",
ADD COLUMN     "restaurantId" TEXT NOT NULL;

-- AlterTable
CREATE SEQUENCE order_ordernumber_seq;
ALTER TABLE "Order" DROP COLUMN "branchId",
ADD COLUMN     "paymentMethod" "PaymentMethod" NOT NULL DEFAULT 'CASH',
ADD COLUMN     "paymentStatus" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
ADD COLUMN     "restaurantId" TEXT NOT NULL,
ALTER COLUMN "orderNumber" SET DEFAULT nextval('order_ordernumber_seq');
ALTER SEQUENCE order_ordernumber_seq OWNED BY "Order"."orderNumber";

-- AlterTable
ALTER TABLE "Product" DROP COLUMN "branchId",
ADD COLUMN     "restaurantId" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "restaurantId" TEXT,
ADD COLUMN     "role" "UserRole" NOT NULL DEFAULT 'CASHIER';

-- DropTable
DROP TABLE "Branch";

-- DropTable
DROP TABLE "Modifier";

-- DropTable
DROP TABLE "ModifierGroup";

-- DropTable
DROP TABLE "OrderItemModifier";

-- DropTable
DROP TABLE "Payment";

-- DropTable
DROP TABLE "ProductModifierGroup";

-- DropTable
DROP TABLE "UserBranch";

-- CreateTable
CREATE TABLE "Restaurant" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT,
    "phone" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Restaurant_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Category_restaurantId_idx" ON "Category"("restaurantId");

-- CreateIndex
CREATE INDEX "Order_createdById_idx" ON "Order"("createdById");

-- CreateIndex
CREATE INDEX "Order_status_idx" ON "Order"("status");

-- CreateIndex
CREATE UNIQUE INDEX "Order_restaurantId_orderNumber_key" ON "Order"("restaurantId", "orderNumber");

-- CreateIndex
CREATE INDEX "OrderItem_orderId_idx" ON "OrderItem"("orderId");

-- CreateIndex
CREATE INDEX "OrderItem_productId_idx" ON "OrderItem"("productId");

-- CreateIndex
CREATE INDEX "Product_categoryId_idx" ON "Product"("categoryId");

-- CreateIndex
CREATE INDEX "Product_restaurantId_idx" ON "Product"("restaurantId");

-- CreateIndex
CREATE INDEX "User_restaurantId_idx" ON "User"("restaurantId");

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_restaurantId_fkey" FOREIGN KEY ("restaurantId") REFERENCES "Restaurant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Category" ADD CONSTRAINT "Category_restaurantId_fkey" FOREIGN KEY ("restaurantId") REFERENCES "Restaurant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Product" ADD CONSTRAINT "Product_restaurantId_fkey" FOREIGN KEY ("restaurantId") REFERENCES "Restaurant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Order" ADD CONSTRAINT "Order_restaurantId_fkey" FOREIGN KEY ("restaurantId") REFERENCES "Restaurant"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
