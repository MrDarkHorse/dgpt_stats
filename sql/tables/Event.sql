CREATE TABLE `Event` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) DEFAULT NULL,
  `pdga_event_id` int(10) unsigned DEFAULT NULL,
  `purse` int(45) unsigned DEFAULT NULL,
  `startdate` date DEFAULT NULL,
  `enddate` date DEFAULT NULL,
  `rounds` tinyint(4) DEFAULT NULL,
  `td` varchar(99) DEFAULT NULL,
  `location` varchar(99) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tour_id_UNIQUE` (`pdga_event_id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8;
