-- 1. Souscription de clients + passage d'une commande + affichage des commandes en attente
call p_create_user("M","Pouce","André","andre-pouce@pouce.com","0102030407",1,1);
call p_create_address(35,"rue Casimir","Lyon","69007"); 

call p_create_user("M","Ventura","Lino","lino-ventura@ventura.com","0102030406",1,1);
call p_create_address(5,"bld marechal","Lyon","69003");

call p_fill_order(8, 4, 2, 1);

call p_print_waiting_orders();
select * from v_print_status where status_id = 2 order by current_datetime;
-- ---------------------------------------------------------------------------------

-- 2. passage d'une autre commande + affichage des commandes en attente
call p_fill_order(7, 4, 1, 0);
call p_fill_order(7, 3, 2, 1);

call p_print_waiting_orders();
select * from v_print_status where status_id = 2 order by current_datetime;
-- ---------------------------------------------------------------------------------

-- 3. modification d'une commande params : command_id, product_id, new_product_id, quantity:
call p_modify_order(4, 3, 2, 2);
call p_command_detail(4);
call p_print_waiting_orders();
select * from v_print_status where status_id = 2 order by current_datetime;
-- ---------------------------------------------------------------------------------

-- 4. Nouveau client sur le pdv1 + Nouvelle commande + Annulation
CALL p_create_user("F","Roberts","Julia","julia-roberts@roberts.com","0706040303",1,1);
CALL p_create_address(17,"chemin de la grande rue","Lyon","69004");

call p_fill_order(9, 1, 1, 1);

call p_print_waiting_orders();

call p_cancel_order(8);
call p_print_waiting_orders();
-- ---------------------------------------------------------------------------------

-- 5-1. Affichage stock + activation de la prépa + affichege du détail de la commande à préparer
select * from v_print_status where status_id = 2 order by current_datetime;
call p_print_stock(1); -- pdv1
call p_start_preparation(5); -- la prépa est lancée, plus de modif ou d'annulation possible
call p_print_waiting_orders();
select * from v_details_preparation;
select * from v_print_status where status_id = 3 order by current_datetime;
-- ---------------------------------------------------------------------------------

-- 5-2. Affichage stock + activation de la prépa + affichege du détail de la commande à préparer
select * from v_print_status where status_id = 2 order by current_datetime;
call p_print_stock(1); -- pdv1
call p_start_preparation(4); -- la prépa est lancée, plus de modif ou d'annulation possible
call p_print_waiting_orders();
select * from v_details_preparation;
select * from v_print_status where status_id = 3 order by current_datetime;
-- ---------------------------------------------------------------------------------

-- 6-1. affichage du statut des commandes + fin de préparation + affichage des stocks
select * from v_print_status where status_id = 3 order by current_datetime;
call p_end_preparation(4);
call p_print_stock(1); -- pdv1
select * from v_print_status where status_id = 4 order by current_datetime;
-- ---------------------------------------------------------------------------------

-- 6-2. affichage du statut des commandes + fin de préparation + affichage des stocks
select * from v_print_status where status_id = 3 order by current_datetime;
call p_end_preparation(5);
call p_print_stock(1); -- pdv1
select * from v_print_status where status_id = 4 order by current_datetime;
-- ---------------------------------------------------------------------------------

-- 7-1. affichage du statut des commandes + affichage des détails pour livraison + départ pour livraison
select * from v_print_status where status_id = 4 order by current_datetime;
call select * from v_print_delivery_informations;
call p_start_delivery(5);
select * from v_print_status where status_id = 5 order by current_datetime;
-- ---------------------------------------------------------------------------------

-- 7-2. affichage du statut des commandes + affichage des détails pour livraison + départ pour livraison
select * from v_print_status where status_id = 4 order by current_datetime;
call select * from v_print_delivery_informations;
call p_start_delivery(4);
select * from v_print_status where status_id = 5 order by current_datetime;
-- ---------------------------------------------------------------------------------

-- 8-1. livraison effectuée + affichage du status des commandes livrées
call p_end_delivery(5);
select * from v_print_status where status_id = 6 order by current_datetime;
-- ---------------------------------------------------------------------------------

-- 8-2. livraison effectuée + affichage du status des commandes livrées
select * from v_print_status where status_id = 5 order by current_datetime;
call p_end_delivery(4);
select * from v_print_status where status_id = 6 order by current_datetime;