-- 1. Souscription de clients + passage d'une commande + affichage des commandes en attente
SET autocommit = 0;
START TRANSACTION;

call p_create_user("M","Pouce","André","andre-pouce@pouce.com","0102030407",1,1);
call p_create_address(35,"rue Casimir","Lyon","69007"); 

call p_create_user("M","Ventura","Lino","lino-ventura@ventura.com","0102030406",1,1);
call p_create_address(5,"bld marechal","Lyon","69003");


call p_fill_order(8, 4, 2, 1);

select * from v_print_status where status_id = 2 order by current_datetime;
COMMIT;
-- ---------------------------------------------------------------------------------

-- 2. passage d'une autre commande + affichage des commandes en attente
START TRANSACTION;
call p_fill_order(7, 4, 1, 0);
call p_fill_order(7, 3, 2, 1);

select * from v_print_status where status_id = 2 order by current_datetime;
COMMIT;
-- ---------------------------------------------------------------------------------

-- Commande sur place (avec le nom du caissier et l'adresse de la pizzeria)
START TRANSACTION;
call p_fill_order(4, 4, 1, 0);
call p_fill_order(4, 1, 2, 0);
call p_fill_order(4, 2, 1, 1);

select * from v_print_status where status_id = 2 order by current_datetime;
COMMIT;

-- 3. modification d'une commande -> params : command_id, product_id, new_product_id, quantity:
START TRANSACTION;
call p_modify_order(4, 3, 2, 2);
call p_command_detail(4);

call p_print_waiting_orders();
select * from v_print_status where status_id = 2 order by current_datetime;
COMMIT;
-- ---------------------------------------------------------------------------------

-- 4. Nouveau client sur le pdv1 + Nouvelle commande + Annulation
START TRANSACTION;
CALL p_create_user("F","Roberts","Julia","julia-roberts@roberts.com","0706040303",1,1);
CALL p_create_address(17,"chemin de la grande rue","Lyon","69004");

call p_fill_order(9, 1, 1, 1);

call p_print_waiting_orders(); -- ici on doit voir les 3 commandes

call p_cancel_order(8); -- c'est la commande n° 8
call p_print_waiting_orders(); -- et ici 2 deux 1eres (normalement)
COMMIT;
-- ---------------------------------------------------------------------------------

-- 5-1. Affichage stock + activation de la prépa + affichage du détail de la commande à préparer
START TRANSACTION;
select * from v_print_status where status_id = 2 order by current_datetime;
call p_print_stock(1); -- pdv1
call p_start_preparation(5); -- la prépa est lancée, plus de modif ou d'annulation possible
select * from v_details_preparation;
select * from v_print_status where status_id = 3 order by current_datetime;
COMMIT;
-- ---------------------------------------------------------------------------------

-- 5-2. Affichage stock + activation de la prépa + affichage du détail de la commande à préparer
START TRANSACTION;
select * from v_print_status where status_id = 2 order by current_datetime;
call p_print_stock(1); -- pdv1
call p_start_preparation(4); -- la prépa est lancée, plus de modif ou d'annulation possible
select * from v_details_preparation;
select * from v_print_status where status_id = 3 order by current_datetime;
COMMIT;
-- ---------------------------------------------------------------------------------

-- 5-3. Affichage stock + activation de la prépa + affichage du détail de la commande à préparer
-- à remettre sur place
START TRANSACTION;
select * from v_print_status where status_id = 2 order by current_datetime;
call p_print_stock(1); -- pdv1
call p_start_preparation(1); -- la prépa est lancée, plus de modif ou d'annulation possible
select * from v_details_preparation;
select * from v_print_status where status_id = 3 order by current_datetime;
COMMIT;

-- 6-1. affichage du statut des commandes + fin de préparation + affichage des stocks
START TRANSACTION;
select * from v_print_status where status_id = 3 order by current_datetime;
call p_end_preparation(4);
call p_print_stock(1); -- pdv1
select * from v_print_status where status_id = 5 order by current_datetime;
COMMIT;
-- ---------------------------------------------------------------------------------

-- 6-2. affichage du statut des commandes + fin de préparation + affichage des stocks
START TRANSACTION;
select * from v_print_status where status_id = 3 order by current_datetime;
call p_end_preparation(5);
call p_print_stock(1); -- pdv1
select * from v_print_status where status_id = 5 order by current_datetime;
COMMIT;
-- ---------------------------------------------------------------------------------

-- 6-3. affichage du statut des commandes + fin de préparation + affichage des stocks
-- à remettre sur place (status_id = 4)
START TRANSACTION;
select * from v_print_status where status_id = 3 order by current_datetime;
call p_end_preparation(1);
call p_print_stock(1); -- pdv1
select * from v_print_status where status_id = 4 order by current_datetime;
select * from v_print_status where status_id = 4 or status_id = 5 order by current_datetime;
COMMIT;
-- ---------------------------------------------------------------------------------

-- 7-0 service sur place, changement de statut "servie" + "payée"
-- ---------------------------------------------------------------------------------

-- 7-1. affichage du statut des commandes + affichage des détails pour livraison + départ pour livraison
START TRANSACTION;
select * from v_print_status where status_id = 5 order by current_datetime;
call p_delivery_info(5);
call p_start_delivery(5);
select * from v_print_status where status_id = 6 order by current_datetime;
COMMIT;
-- ---------------------------------------------------------------------------------

-- 7-2. affichage du statut des commandes + affichage des détails pour livraison + départ pour livraison
START TRANSACTION;
select * from v_print_status where status_id = 5 order by current_datetime;
call p_delivery_info(4); -- Attention, ici, plus d'affichage sur le 2e
call p_start_delivery(4);
select * from v_print_status where status_id = 6 order by current_datetime;
COMMIT;
-- ---------------------------------------------------------------------------------

-- 8-1. livraison effectuée + affichage du status des commandes livrées
START TRANSACTION;
select * from v_print_status where status_id = 6 order by current_datetime;
call p_end_delivery(5);
call p_delivery_info(5);
COMMIT;
-- ---------------------------------------------------------------------------------

-- 8-2. livraison effectuée + affichage du status des commandes livrées
START TRANSACTION;
select * from v_print_status where status_id = 6 order by current_datetime;
call p_end_delivery(4);
call p_delivery_info(4);
COMMIT;
