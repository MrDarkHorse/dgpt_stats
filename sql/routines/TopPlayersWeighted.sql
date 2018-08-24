-- CALL TopPlayersWeighted(NULL, NULL, 0.025, 75, 50);

DROP PROCEDURE IF EXISTS `TopPlayersWeighted`;

DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `TopPlayersWeighted`(the_startdate DATETIME, the_enddate DATETIME, the_weight_degredation FLOAT, the_num_qualifying_players_considered INT, the_num_qualifying_players INT)
    READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

IF the_startdate IS NULL THEN
  SET the_startdate = '1000-01-01';
END IF;

IF the_enddate IS NULL THEN
  SET the_enddate = '9999-12-31';
END IF;

START TRANSACTION;

CALL DetermineTopPlayers(the_startdate, the_enddate, the_weight_degredation, the_num_qualifying_players_considered);
CALL DetermineWeightedScores(the_startdate, the_enddate, the_weight_degredation, the_num_qualifying_players);

SELECT *
FROM tmp_weighted_results
ORDER BY weighted_win_pct desc
LIMIT the_num_qualifying_players;

COMMIT;

END;;
DELIMITER ;
