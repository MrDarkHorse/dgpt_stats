DROP PROCEDURE IF EXISTS `DetermineTopPlayers`;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `DetermineTopPlayers`(the_startdate DATETIME, the_enddate DATETIME, the_weight_degredation FLOAT, the_num_qualifying_players INT, the_num_top_players INT)
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

  -- copy the contents of the EventWinLoss view into a scratch space table
  -- (don't use a temporary table because we need to reference the table more than once in a single query)
  drop table if exists tmp_event_win_loss_cpy;
  create table tmp_event_win_loss_cpy
    SELECT *
    FROM EventWinLoss;

  -- determine the top qualifying players
  drop table if exists tmp_qualifying_players;
  create table tmp_qualifying_players
    SELECT *
      FROM (SELECT p.id, p.name, r.rating, (select COUNT(*) from Result r join QualifyingEvents qe ON qe.pdga_event_id = r.event_id where r.player_id = p.id) as events,
      (select SUM(wins) from tmp_event_win_loss_cpy where player_id = p.id AND startdate >= the_startdate AND enddate <= the_enddate) as wins,
      (select SUM(losses) from tmp_event_win_loss_cpy where player_id = p.id AND startdate >= the_startdate AND enddate <= the_enddate) as losses,
      (select SUM(ties) from tmp_event_win_loss_cpy where player_id = p.id AND startdate >= the_startdate AND enddate <= the_enddate) as ties,
      (select (wins + (ties/2)) / (wins+losses+ties)) as win_pct,
      (select (events * 10 + (wins + (ties/2)))) as qual_pts
      FROM Player AS p
      JOIN Result AS r ON p.id = r.player_id
      JOIN QualifyingEvents AS e ON e.pdga_event_id = r.event_id
      WHERE r.rating > 1000
      GROUP BY r.player_id
      ORDER BY qual_pts desc) subquery
    LIMIT the_num_qualifying_players;

  -- determine the top players
  drop table if exists tmp_top_players;
  create table tmp_top_players
    SELECT * FROM tmp_qualifying_players
    ORDER BY win_pct desc
    LIMIT the_num_top_players;

  -- recalculate win/loss using only top players selected above
  drop table if exists tmp_event_qualifying_win_loss;
  create table tmp_event_qualifying_win_loss
    SELECT
       `e`.`pdga_event_id` AS `event_id`,
       `e`.`name` AS `event`,
       `p`.`id` AS `player_id`,
       `p`.`name` AS `player`,
       (select count(0) from `result` where ((`result`.`event_id` = `r`.`event_id`) and (`r`.`rank` < `result`.`rank`) and (`result`.`rating` > 999) and player_id IN (SELECT id from tmp_top_players))) AS `wins`,
       (select count(0) from `result` where ((`result`.`event_id` = `r`.`event_id`) and (`r`.`rank` > `result`.`rank`) and (`result`.`rating` > 999) and player_id IN (SELECT id from tmp_top_players))) AS `losses`,
       (select count(0) from `result` where ((`result`.`event_id` = `r`.`event_id`) and (`r`.`rank` = `result`.`rank`) and (`result`.`rating` > 999) and player_id IN (SELECT id from tmp_top_players))) AS `ties`,
       `e`.`startdate` AS `startdate`,
       `e`.`enddate` AS `enddate`
     from ((`event` `e`
       join `result` `r` on((`e`.`pdga_event_id` = `r`.`event_id`)))
       join `player` `p` on((`p`.`id` = `r`.`player_id`)))
     where (`r`.`rating` > 999)
     and startdate >= the_startdate
     and enddate <= the_enddate
     and r.event_id IN (SELECT pdga_event_id FROM QualifyingEvents)
     group by `e`.`pdga_event_id`,`r`.`player_id`
     order by `e`.`id`,`wins` desc;

END;;
DELIMITER ;
