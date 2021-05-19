SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ocpizza
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema ocpizza
-- -----------------------------------------------------
DROP DATABASE IF EXISTS `ocpizza` ;

CREATE SCHEMA IF NOT EXISTS `ocpizza` DEFAULT CHARACTER SET UTF8MB4 ;
USE `ocpizza` ;

-- -----------------------------------------------------
-- Table `ocpizza`.`address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`address` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `number` TINYINT(5) NULL,
  `street_name` VARCHAR(100) NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `zip_code` CHAR(5) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`pizzeria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`pizzeria` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `address_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_pizzeria_address1_idx` (`address_id` ASC) VISIBLE,
  CONSTRAINT `fk_pizzeria_address1`
    FOREIGN KEY (`address_id`)
    REFERENCES `ocpizza`.`address` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`user` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sex` CHAR(1) NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `first_name` VARCHAR(100) NOT NULL,
  `phone_number` VARCHAR(10) NOT NULL,
  `pizzeria_id` INT NOT NULL,
  PRIMARY KEY (`id`, `pizzeria_id`),
  UNIQUE INDEX `phone_number_UNIQUE` (`phone_number` ASC) VISIBLE,
  INDEX `fk_user_pizzeria1_idx` (`pizzeria_id` ASC) VISIBLE,
  CONSTRAINT `fk_user_pizzeria1`
    FOREIGN KEY (`pizzeria_id`)
    REFERENCES `ocpizza`.`pizzeria` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`role`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`role` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`user_role`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`user_role` (
  `user_id` INT NOT NULL,
  `role_id` INT NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`),
  INDEX `fk_user_has_role_role1_idx` (`role_id` ASC) VISIBLE,
  INDEX `fk_user_has_role_user1_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_user_role_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `ocpizza`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_role_role1`
    FOREIGN KEY (`role_id`)
    REFERENCES `ocpizza`.`role` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`ingredient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`ingredient` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`product` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  `price` DECIMAL(5,2) NULL,
  `recipe` TEXT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`status`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`status` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`command`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`command` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `current_datetime` DATETIME NULL DEFAULT (now()),
  `delivery_address` TEXT NULL,
  `total_amount` DECIMAL NULL,
  `is_on_site_or_online` BOOLEAN,
  `pizzeria_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `status_id` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`, `pizzeria_id`, `user_id`, `status_id`),
  INDEX `fk_command_pizzeria1_idx` (`pizzeria_id` ASC) VISIBLE,
  INDEX `fk_command_user1_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_command_status1_idx` (`status_id` ASC) VISIBLE,
  CONSTRAINT `fk_command_pizzeria1`
    FOREIGN KEY (`pizzeria_id`)
    REFERENCES `ocpizza`.`pizzeria` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_command_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `ocpizza`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_command_status1`
    FOREIGN KEY (`status_id`)
    REFERENCES `ocpizza`.`status` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`user_has_address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`user_has_address` (
  `user_id` INT NOT NULL,
  `address_id` INT NOT NULL,
  PRIMARY KEY (`user_id`, `address_id`),
  INDEX `fk_user_has_address_address1_idx` (`address_id` ASC) VISIBLE,
  INDEX `fk_user_has_address_user1_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_user_has_address_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `ocpizza`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_has_address_address1`
    FOREIGN KEY (`address_id`)
    REFERENCES `ocpizza`.`address` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`payment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`payment` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `detail` VARCHAR(45) NULL,
  `amount` DECIMAL NULL,
  `date` DATE NOT NULL,
  `command_id` INT NOT NULL,
  PRIMARY KEY (`id`, `command_id`),
  INDEX `fk_payment_command1_idx` (`command_id` ASC) VISIBLE,
  CONSTRAINT `fk_payment_command1`
    FOREIGN KEY (`command_id`)
    REFERENCES `ocpizza`.`command` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`product_has_ingredient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`product_has_ingredient` (
  `product_id` INT NOT NULL,
  `ingredient_id` INT NOT NULL,
  `quantity` INT NULL,
  PRIMARY KEY (`product_id`, `ingredient_id`),
  INDEX `fk_product_has_ingredient_ingredient1_idx` (`ingredient_id` ASC) VISIBLE,
  INDEX `fk_product_has_ingredient_product1_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_product_has_ingredient_product1`
    FOREIGN KEY (`product_id`)
    REFERENCES `ocpizza`.`product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_product_has_ingredient_ingredient1`
    FOREIGN KEY (`ingredient_id`)
    REFERENCES `ocpizza`.`ingredient` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`pizzeria_has_ingredient`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`pizzeria_has_ingredient` (
  `pizzeria_id` INT NOT NULL,
  `ingredient_id` INT NOT NULL,
  `quantity` INT NULL,
  PRIMARY KEY (`pizzeria_id`, `ingredient_id`),
  INDEX `fk_pizzeria_has_ingredient_ingredient1_idx` (`ingredient_id` ASC) VISIBLE,
  INDEX `fk_pizzeria_has_ingredient_pizzeria1_idx` (`pizzeria_id` ASC) VISIBLE,
  CONSTRAINT `fk_pizzeria_has_ingredient_pizzeria1`
    FOREIGN KEY (`pizzeria_id`)
    REFERENCES `ocpizza`.`pizzeria` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_pizzeria_has_ingredient_ingredient1`
    FOREIGN KEY (`ingredient_id`)
    REFERENCES `ocpizza`.`ingredient` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`command_has_product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`command_has_product` (
  `command_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `quantity` INT NULL,
  PRIMARY KEY (`command_id`, `product_id`),
  INDEX `fk_command_has_product_product1_idx` (`product_id` ASC) VISIBLE,
  INDEX `fk_command_has_product_command1_idx` (`command_id` ASC) VISIBLE,
  CONSTRAINT `fk_command_has_product_command1`
    FOREIGN KEY (`command_id`)
    REFERENCES `ocpizza`.`command` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_command_has_product_product1`
    FOREIGN KEY (`product_id`)
    REFERENCES `ocpizza`.`product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`pizzeria_has_product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`pizzeria_has_product` (
  `pizzeria_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `quantity` INT NULL,
  PRIMARY KEY (`pizzeria_id`, `product_id`),
  INDEX `fk_pizzeria_has_product_product1_idx` (`product_id` ASC) VISIBLE,
  INDEX `fk_pizzeria_has_product_pizzeria1_idx` (`pizzeria_id` ASC) VISIBLE,
  CONSTRAINT `fk_pizzeria_has_product_pizzeria1`
    FOREIGN KEY (`pizzeria_id`)
    REFERENCES `ocpizza`.`pizzeria` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_pizzeria_has_product_product1`
    FOREIGN KEY (`product_id`)
    REFERENCES `ocpizza`.`product` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ocpizza`.`email`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ocpizza`.`email` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NULL,
  `user_id` INT NOT NULL,
  PRIMARY KEY (`id`, `user_id`),
  INDEX `fk_email_user1_idx` (`user_id` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  CONSTRAINT `fk_email_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `ocpizza`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;