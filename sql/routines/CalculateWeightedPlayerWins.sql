DROP PROCEDURE IF EXISTS `CalculateWeightedPlayerWins`;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CalculateWeightedPlayerWins`(
  the_player_id INT,
  the_weight_degredation FLOAT,
  OUT the_weighted_wins FLOAT)
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

SELECT SUM(wins * weight) as weighted_wins INTO the_weighted_wins
FROM (
    SELECT e.*, 1 + the_weight_degredation - (the_weight_degredation * (DATEDIFF(now(), e.startdate) / 7)) as weight
      FROM tmp_event_qualifying_win_loss e
      WHERE e.player_id = the_player_id
) subquery;

END;;
DELIMITER ;
