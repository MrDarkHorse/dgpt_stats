CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `eventwinloss`
AS SELECT
   `e`.`pdga_event_id` AS `event_id`,
   `e`.`name` AS `event`,
   `p`.`id` AS `player_id`,
   `p`.`name` AS `player`,
   (select count(0) from `result` where ((`result`.`event_id` = `r`.`event_id`) and (`r`.`rank` < `result`.`rank`) and (`result`.`rating` > 999))) AS `wins`,
   (select count(0) from `result` where ((`result`.`event_id` = `r`.`event_id`) and (`r`.`rank` > `result`.`rank`) and (`result`.`rating` > 999))) AS `losses`,
   (select count(0) from `result` where ((`result`.`event_id` = `r`.`event_id`) and (`r`.`rank` = `result`.`rank`) and (`result`.`rating` > 999))) AS `ties`,
   `e`.`startdate` AS `startdate`,
   `e`.`enddate` AS `enddate`
 from ((`event` `e`
   join `result` `r` on((`e`.`pdga_event_id` = `r`.`event_id`)))
   join `player` `p` on((`p`.`id` = `r`.`player_id`)))
 where (`r`.`rating` > 999)
 group by `e`.`pdga_event_id`,`r`.`player_id`
 order by `e`.`id`,`wins` desc;
