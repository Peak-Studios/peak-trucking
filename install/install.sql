CREATE TABLE IF NOT EXISTS `peak_trucking` (
  `identifier` longtext DEFAULT NULL,
  `points` longtext DEFAULT NULL,
  `unlockedMissions` longtext DEFAULT NULL,
  `dailymissions` longtext DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `xp` int(11) DEFAULT NULL,
  `totalEarnings` int(11) DEFAULT NULL,
  `completedJobs` int(11) DEFAULT NULL,
  `name` longtext DEFAULT NULL,
  `avatar` longtext DEFAULT NULL,
  `history` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;