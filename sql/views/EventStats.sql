CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tmp_eventstats`
AS SELECT
   `e`.`pdga_event_id` AS `pdga_event_id`,
   `e`.`name` AS `name`,
   `e`.`startdate` AS `startdate`,
   `e`.`enddate` AS `enddate`,
   count(`r`.`id`) AS `quality_players`
FROM (`event` `e` join `result` `r` on((`e`.`pdga_event_id` = `r`.`event_id`)))
where (`r`.`rating` > 999)
AND r.player_id IN (SELECT id from tmp_qualifying_players)
group by `e`.`id`;
