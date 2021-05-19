SET autocommit = 0;
START TRANSACTION;

INSERT INTO `ocpizza`.`address`(`number`, `street_name`, `city`, `zip_code`) 
VALUES 
       (3,"rue de la pizzeria 1","Lyon","69003"),
       (2,"rue de la pizzeria 2","Lyon","69004"),
       (1,"rue de la pizzeria 3","Lyon","69005");

INSERT INTO `ocpizza`.`pizzeria`(`name`, `address_id`) 
VALUES ("pdv1",1),
       ("pdv2",2),
       ("pdv3",3);
       
INSERT INTO `ocpizza`.`user`(`sex`, `last_name`, `first_name`, `phone_number`, `pizzeria_id`) 
VALUES ("F","Machine","Léa","0104070205",1),("M","Machin","Fred","0104070206",2),("F","Bidul","Pauline","0104070207",3);       

INSERT INTO `ocpizza`.`email`(`email`, `user_id`) VALUES ("leamachine@ocp.com", 1), ("fredmachin@ocp.com", 2), ("paulinebidule@ocp.com", 3);
       
INSERT INTO `ocpizza`.`address`(`number`, `street_name`, `city`, `zip_code`) 
VALUES 
       (10,"rue des plantes","Lyon","69001"),
       (22,"route du pot","Lyon","69009"),
       (11,"rue neuve","Lyon","69006");
       
INSERT INTO `ocpizza`.`user_has_address`(`user_id`, `address_id`) VALUES (1,4),(2,5),(3,6);

INSERT INTO `ocpizza`.`role`(`name`) VALUES ("client"),("admin"),("cashier"),("pizzaiolo"),("deliverer");

INSERT INTO `ocpizza`.`user_role`(`user_id`, `role_id`) VALUES (1,2),(2,2),(3,2);

INSERT INTO `ocpizza`.`product`(`name`, `price`, `recipe`) 
VALUES ("Margherita", "8.5", "Recette de la margherita"),
       ("Reine", "11.99", "Recette de la Reine"),
       ("Sicilienne", "9.5", "Recette de la Sicilienne"),
       ("Napolitaine", "9.99", "Recette de la Napolitaine");

INSERT INTO `ocpizza`.`ingredient`(`name`)
VALUES ("pate à pizza"),("sauce tomate"),("jambon"),("mozzarella"),
("champignon"),("anchois"),("olive");

INSERT INTO `ocpizza`.`pizzeria_has_product`(`product_id`, `pizzeria_id`, `quantity`) 
VALUES (1,1,0),(2,1,0),(3,1,0),(4,1,0),
       (1,2,0),(2,2,0),(3,2,0),(4,2,0),
       (1,3,0),(2,3,0),(3,3,0),(4,3,0);

INSERT INTO `ocpizza`.`product_has_ingredient`(`product_id` ,`ingredient_id`, `quantity`) 
VALUES (1,1,1),(1,2,2),(1,4,2),
       (2,1,1),(2,2,2),(2,3,1),(2,4,2),(2,5,3),
       (3,1,1),(3,2,2),(3,4,2),(3,5,3),
       (4,1,1),(4,2,2),(4,4,2),(4,6,3),(4,7,5);

INSERT INTO `ocpizza`.`pizzeria_has_ingredient`(`pizzeria_id` ,`ingredient_id`, `quantity`) 
VALUES (1,1,100),(1,2,200),(1,3,100),(1,4,200),(1,5,100),(1,6,100),(1,7,125),
       (2,1,100),(2,2,200),(2,3,100),(2,4,200),(2,5,100),(2,6,100),(2,7,125),
       (3,1,100),(3,2,200),(3,3,100),(3,4,200),(3,5,100),(3,6,100),(3,7,125);

INSERT INTO `ocpizza`.`status`(`name`) VALUES ("Créée"), ("En attente"), ("En préparation"), ("A remettre sur place"), ("A livrer"), ("En livraison"), ("Livrée");

COMMIT;

-- ------------------------------------------------------------------------------
-- Create procedures
-- ------------------------------------------------------------------------------

DELIMITER $$ 
CREATE PROCEDURE p_create_order(p_user_id int, p_pizzeria_id tinyint, p_is_on_site_or_online tinyint)
BEGIN

insert into ocpizza.command (user_id, pizzeria_id) values (p_user_id, p_pizzeria_id);
update command set is_on_site_or_online = p_is_on_site_or_online, status_id = 1 where user_id = p_user_id and status_id < 2;

END $$
DELIMITER ;

-- crate users and association pizzeria / role
DELIMITER $$ 
CREATE PROCEDURE p_create_user (p_sex char(1), p_last_name varchar(100), p_first_name varchar(100), p_email varchar(255), p_phone_num varchar(10), p_pizzeria_id int, p_role_id int)
BEGIN

INSERT INTO `ocpizza`.`user`(`sex`, `last_name`, `first_name`, `phone_number`, `pizzeria_id`) 
VALUES (p_sex, p_last_name, p_first_name, p_phone_num, p_pizzeria_id);

INSERT INTO `ocpizza`.`email`(`email`, `user_id`) VALUES (p_email, (SELECT max(user.id) from user));

INSERT INTO `ocpizza`.`user_role`(`user_id`, `role_id`) 
values ((SELECT max(user.id) from user), p_role_id);

CALL p_create_order((SELECT max(user.id) from user), p_pizzeria_id, (select if(p_role_id = 1, 1, 0)));

END $$
DELIMITER ; 

DELIMITER $$ 
CREATE PROCEDURE p_create_address(p_street_num tinyint(5), p_street_name varchar(100), p_city varchar(100), p_zip_code char(5))
BEGIN
INSERT INTO `ocpizza`.`address`(`number`, `street_name`, `city`, `zip_code`) 
VALUES (p_street_num, p_street_name, p_city, p_zip_code);

INSERT INTO `ocpizza`.`user_has_address`(`user_id`, `address_id`) 
SELECT max(u.id), max(a.id)
from user u
join address a;
END $$
DELIMITER ; 

CALL p_create_user("M","McCashier","Simbad","mc_cashier@ocp.com","0605040303",1,3);
CALL p_create_address(7,"chemin de la route","Lyon","69008");

CALL p_create_user("M", "Cuisto","Jimi","cuisto@ocp.com","0605040304",1,4);
CALL p_create_address(66,"rue des monts","Lyon","69006");

CALL p_create_user("M", "Deroux","Ben","deroux@ocp.com","0605040305",1,5); 
CALL p_create_address(77,"route du banco","Lyon","69007");

DELIMITER $$ 
CREATE PROCEDURE p_fill_order(p_user_id int, p_product_id int, p_quantity int, p_is_finished boolean)
BEGIN
update command 
join (select max(id) mx_id from command where user_id = p_user_id) a
on a.mx_id = command.id
set current_datetime = now();

IF p_is_finished = True THEN

insert into command_has_product (product_id, command_id, quantity)
values (p_product_id,(select max(id) from command where user_id = p_user_id), p_quantity);
update command set current_datetime = now(), status_id = 2 where user_id = p_user_id;

update command set delivery_address = (
select if((select role.id from role join user_role ur on ur.role_id = role.id join user on user.id = ur.user_id where user.id = p_user_id) = 3, 
concat(user.first_name, ' ', user.last_name, ' ', address_piz.number, ' ', address_piz.street_name, ', ', address_piz.zip_code, ', ', address_piz.city),
concat(user.first_name, ' ', user.last_name, ' ', address_cust.number, ' ', address_cust.street_name, ', ', address_cust.zip_code, ', ', address_cust.city))
from user
join pizzeria p on p.address_id = user.pizzeria_id
join address address_piz on address_piz.id = p.address_id
join user_has_address uha on uha.user_id = user.id
join address address_cust on address_cust.id = uha.address_id
where p.id = (select p.id from pizzeria p join user on user.pizzeria_id = p.id where user.id = p_user_id) and user.id = p_user_id)
where command.user_id = p_user_id;

call p_create_order(p_user_id,(select pizzeria_id from user where id = p_user_id), (select is_on_site_or_online from command where user_id = p_user_id));

ELSE

insert into command_has_product (product_id, command_id, quantity)
values (p_product_id,(select max(id) from command where user_id = p_user_id and status_id = 1), p_quantity);

END IF;
END $$
DELIMITER ;

-- starting preparation
DELIMITER $$ 
CREATE PROCEDURE p_start_preparation(p_command_id int)
BEGIN

update command 
set status_id = 3, current_datetime = now() where id = p_command_id;

END $$
DELIMITER ;

-- prepared command, update statut ready to delivery
DELIMITER $$ 
CREATE PROCEDURE p_end_preparation(p_command_id int)
BEGIN

IF (select status_id from command where id = p_command_id) = 3 THEN
call p_substract_stock(p_command_id);
update command 
set status_id = if(is_on_site_or_online  = 0,  4, 5) where status_id = 3 and id = p_command_id;
-- set status_id = 4 where status_id = 3 and id = p_command_id;
END IF;

END $$
DELIMITER ;

-- stock updating
DELIMITER $$ 
CREATE PROCEDURE p_substract_stock(p_command_id int)
BEGIN

IF (
select status_id 
from command 
where id = p_command_id) = 3 
THEN

update pizzeria_has_ingredient phi
join command c
on c.pizzeria_id = phi.pizzeria_id
join pizzeria p
on p.id = phi.pizzeria_id
join command_has_product phc
on phc.command_id = c.id
join product_has_ingredient prhi
on prhi.ingredient_id = phi.ingredient_id
join ingredient i
on i.id = prhi.ingredient_id

-- 1, 2 and 4 are common to all the recipes, the updates are made for the total of the products
-- the rest is updated for the specific ingredients in there
set phi.quantity = phi.quantity - (prhi.quantity * if(prhi.ingredient_id in (1,2,4), 
    (select sum(command_has_product.quantity) 
     from command_has_product 
     where command_id = p_command_id), phc.quantity))
where phc.command_id = p_command_id and prhi.product_id = phc.product_id;

END IF;

END $$
DELIMITER ;

-- cancel command before preparation
DELIMITER $$ 
CREATE PROCEDURE p_cancel_order(p_command_id int)
BEGIN
delete from command_has_product 
where command_id = p_command_id and (select status_id from command where id = p_command_id) < 3;
delete from command where id = p_command_id and status_id < 3;
END $$
DELIMITER ;

-- Modify command by row
DELIMITER $$ 
CREATE PROCEDURE p_modify_order(p_command_id int, p_product_id tinyint, p_new_product_id tinyint, p_new_quantity tinyint)
BEGIN
update command_has_product 
join command
set quantity = p_new_quantity, product_id = p_new_product_id
where product_id = p_product_id and command_id = p_command_id and (select status_id from command where id = p_command_id) < 3;
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE p_print_stock(p_pizzeria_id int)
BEGIN
select * from v_print_stock where id = p_pizzeria_id;
END $$
DELIMITER ;



-- starting preparation
DELIMITER $$ 
CREATE PROCEDURE DELIMITER $$ 
CREATE PROCEDURE p_start_delivery(p_command_id int)
BEGIN

update command 
set status_id = 6, current_datetime = now() where id = p_command_id;

END $$
DELIMITER ;


-- prepared command, update statut ready to delivery
DELIMITER $$ 
CREATE PROCEDURE p_end_delivery(p_command_id int)
BEGIN

update command 
set status_id = 7 where status_id = 6 and id = p_command_id;

END $$
DELIMITER ;

-- DELIMITER $$ 
-- CREATE PROCEDURE wtf(p_command_id int)
-- BEGIN

-- update command 
-- set status_id = 5, current_datetime = now() where id = p_command_id;

-- END $$
-- DELIMITER ;

-- command detail by command id
DELIMITER $$ 
CREATE PROCEDURE p_command_detail(p_command_id int)
BEGIN
select user_id 'identifiant utilisateur', 
  product.name produit, 
    price 'prix unitaire', 
    price*quantity 'prix total produit x quantité', 
    quantity 'quantité', 
    command_id 'identifiant de la commande', 
    status_id, (
    select sum(price*quantity) 
    from command
    join command_has_product
    on command_has_product.command_id = command.id
    join product
    on product.id = command_has_product.product_id
     where command_id = p_command_id
    ) 'prix total de la commande', is_command_ready from command
join command_has_product
on command_has_product.command_id = command.id
join product
on product.id = command_has_product.product_id
where command_id = p_command_id
order by command_id;
END $$
DELIMITER ;


-- command bill or detail for delivery
DELIMITER $$ 
CREATE PROCEDURE p_command_bill(p_command_id int)
BEGIN
select uha.user_id 'identifiant utilisateur', 
  user.first_name, 
    user.last_name,  
    product.name produit, 
    price 'prix unitaire', 
    price*quantity 'prix total produit x quantité', 
    quantity 'quantité', 
    command_id 'identifiant de la commande', 
    status.name 'statut du process', (
    select sum(price*quantity) 
    from command
    join command_has_product
    on command_has_product.command_id = command.id
    join product
    on product.id = command_has_product.product_id
     where command_id = p_command_id
    ) 'prix total de la commande', 
    DATE_FORMAT(current_datetime, '%d-%m-%y') command_date, 
    command.delivery_address 'adresse de livraison'
    from command
  join command_has_product
  on command_has_product.command_id = command.id
  join product
  on product.id = command_has_product.product_id
  join status on status.id = command.status_id
  join user on user.id = command.user_id
  join user_has_address uha on uha.user_id = user.id 
  join address a on a.id = uha.address_id
  where command_id = p_command_id;
END $$
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE p_delivery_info(p_command_id int)
BEGIN

select * from v_print_delivery_informations where id_de_commande = p_command_id and status_id in (5,6,7);

END $$
DELIMITER ;

-- ----------------------------------------------------------------------------
-- Create views
-- ----------------------------------------------------------------------------

CREATE VIEW v_details_preparation AS 
select user_id user_id, 
product.name 'nom du produit', 
quantity 'quantité', 
recipe recette,
command_id 'numéro de commande', 
s.name 'statut de la commande', 
status_id,
current_datetime
from command
join command_has_product
on command_has_product.command_id = command.id
join product
on product.id = command_has_product.product_id
join status s
on s.id = command.status_id
where status_id = 3 order by current_datetime;

CREATE VIEW v_print_stock AS 
select distinct ingredient.name ingredient, phi.quantity, pizzeria.id
from pizzeria_has_ingredient phi
join pizzeria on phi.pizzeria_id = pizzeria.id
join ingredient on ingredient.id = phi.ingredient_id;


-- follow_status -------------------------------------------
CREATE VIEW v_print_status AS 
select command.id 'N° de commande', 
     current_datetime, 
     status.name 'statut de la commande',
     command.status_id
from command
join user on user.id = command.user_id
join status on status.id = command.status_id;


CREATE VIEW v_print_waiting_orders AS 
select * from v_print_status where status_id = 2 order by current_datetime;

-- delivery informations -----------------------------------
CREATE VIEW v_print_delivery_informations AS
select command.delivery_address 'étiquette adresse', command.id id_de_commande, 
     DATE_FORMAT(current_datetime, '%d-%m-%Y') 'date de la commande', 
       status.name 'statut de la commande',
       status_id
from command
join user on user.id = command.user_id
join status on status.id = command.status_id;