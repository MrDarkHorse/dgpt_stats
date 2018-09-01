DROP PROCEDURE IF EXISTS `CalculateWeightedPlayerWins`;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CalculateWeightedPlayerWins`(
  the_player_id INT,
  the_weight_degredation FLOAT,
  OUT the_weighted_wins FLOAT,
  OUT the_weighted_ties FLOAT)
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

SELECT SUM(wins * weight) as weighted_wins, SUM(ties * weight) as weighted_ties INTO the_weighted_wins, the_weighted_ties
FROM (
    SELECT e.*, 1 + the_weight_degredation - (the_weight_degredation * (DATEDIFF(now(), e.startdate) / 7)) as weight
      FROM tmp_event_qualifying_win_loss e
      WHERE e.player_id = the_player_id
) subquery;

END;;
DELIMITER ;
