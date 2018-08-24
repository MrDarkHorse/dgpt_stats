-- CALL DetermineWeightedScores(NULL, NULL, 0.025, 75, 50);

DROP PROCEDURE IF EXISTS `DetermineWeightedScores`;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `DetermineWeightedScores`(the_startdate DATETIME, the_enddate DATETIME, the_weight_degredation FLOAT, the_num_qualifying_players_considered INT)
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

  DECLARE is_finished INTEGER DEFAULT FALSE;
  DECLARE tmp_player_id INT UNSIGNED;
  DECLARE tmp_weighted_wins FLOAT UNSIGNED;

  DECLARE player_ids CURSOR FOR
    SELECT id
    FROM tmp_qualifying_players;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET is_finished = 1;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
       RESIGNAL;
    END;

  drop temporary table if exists tmp_weighted_results;
  create temporary table tmp_weighted_results (
    `player_id` int(10) unsigned NOT NULL,
    `name` VARCHAR(99) NOT NULL,
    `rating` int(10) unsigned NOT NULL,
    `events` int(10) unsigned NOT NULL,
    `wins` int(10) unsigned ,
    `losses` int(10) unsigned ,
    `ties` int(10) unsigned ,
    `weighted_wins` FLOAT unsigned ,
    `win_pct` FLOAT unsigned ,
    `weighted_win_pct` FLOAT unsigned ,
    `qual_pts` int(10) unsigned ,
    PRIMARY KEY (`player_id`)
  ) DEFAULT CHARSET=utf8;

  drop temporary table if exists tmp_event_win_loss;
  create temporary table tmp_event_win_loss
  SELECT *
    FROM (
      SELECT p.id, p.name, r.rating, (select COUNT(*) from Result where player_id = p.id) as events,
      (select SUM(wins) from tmp_event_qualifying_win_loss where player_id = p.id) as wins,
      (select SUM(losses) from tmp_event_qualifying_win_loss where player_id = p.id) as losses,
      (select SUM(ties) from tmp_event_qualifying_win_loss where player_id = p.id) as ties,
      (select wins / (wins+losses+ties)) as win_pct,
      (select events * 10 + (wins+losses)) as qual_pts
      FROM Player AS p
      JOIN Result AS r ON p.id = r.player_id
      JOIN Event AS e ON e.pdga_event_id = r.event_id
      WHERE r.player_id IN (SELECT id from tmp_qualifying_players)
      GROUP BY r.player_id
      LIMIT the_num_qualifying_players_considered) subquery;

  OPEN player_ids;

      each_player_id: LOOP
          FETCH player_ids INTO tmp_player_id;
          IF is_finished = 1 THEN
              LEAVE each_player_id;
          END IF;

          CALL CalculateWeightedPlayerWins(tmp_player_id, the_weight_degredation, tmp_weighted_wins);
          INSERT INTO tmp_weighted_results (player_id, name, rating, events, wins, losses, ties, win_pct, qual_pts)
          SELECT id, name, rating, events, wins, losses, ties, win_pct, qual_pts
          FROM tmp_event_win_loss
          WHERE id = tmp_player_id;

          UPDATE tmp_weighted_results
          SET weighted_wins = tmp_weighted_wins,
          weighted_win_pct = tmp_weighted_wins / (wins + ties + losses)
          WHERE player_id = tmp_player_id;

      END LOOP each_player_id;
  CLOSE player_ids;

END;;
DELIMITER ;
