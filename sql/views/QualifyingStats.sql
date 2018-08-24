CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `qualifyingstats`
AS SELECT
   `p`.`id` AS `id`,
   `p`.`name` AS `name`,(select count(0)
FROM `result`
where (`result`.`player_id` = `p`.`id`)) AS `events`,
(select sum(`eventwinloss`.`wins`) from `eventwinloss` where (`eventwinloss`.`player_id` = `p`.`id`)) AS `wins`,
(select sum(`eventwinloss`.`losses`) from `eventwinloss` where (`eventwinloss`.`player_id` = `p`.`id`)) AS `losses`,
(select sum(`eventwinloss`.`ties`) from `eventwinloss` where (`eventwinloss`.`player_id` = `p`.`id`)) AS `ties`,
(select (`wins` / ((`wins` + `losses`) + `ties`))) AS `win_pct`,
(select ((`events` * 10) + ((`wins` + `losses`) + `ties`))) AS `qual_pts`
from (`player` `p` join `result` `r` on((`p`.`id` = `r`.`player_id`)))
where (`r`.`rating` > 999)
group by `r`.`player_id`
order by `qual_pts` desc
limit 50;
