CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `top50`
AS SELECT
   `qualifyingstats`.`id` AS `id`,
   `qualifyingstats`.`name` AS `name`,
   `qualifyingstats`.`events` AS `events`,
   `qualifyingstats`.`wins` AS `wins`,
   `qualifyingstats`.`losses` AS `losses`,
   `qualifyingstats`.`ties` AS `ties`,
   `qualifyingstats`.`win_pct` AS `win_pct`,
   `qualifyingstats`.`qual_pts` AS `qual_pts`
FROM `qualifyingstats` order by `qualifyingstats`.`win_pct` desc;
