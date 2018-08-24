CREATE TABLE `Result` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `player_id` int(10) unsigned NOT NULL,
  `event_id` int(10) unsigned NOT NULL,
  `prize` int(10) unsigned DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  `rank` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`,`player_id`,`event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4191 DEFAULT CHARSET=utf8;
