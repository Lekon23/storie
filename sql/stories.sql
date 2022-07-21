-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1:3306
-- Время создания: Июн 01 2022 г., 18:37
-- Версия сервера: 5.7.33-log
-- Версия PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `stories_mode`
--

-- --------------------------------------------------------

--
-- Структура таблицы `bans`
--

CREATE TABLE `bans` (
  `id` int(11) NOT NULL,
  `type` int(1) NOT NULL,
  `ban_date` int(255) NOT NULL,
  `ban_time` int(255) NOT NULL,
  `ban_ip` varchar(16) NOT NULL,
  `ban_nickname` varchar(24) NOT NULL,
  `ban_reason` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Структура таблицы `factions`
--

CREATE TABLE `factions` (
  `id` int(11) NOT NULL,
  `name` varchar(35) NOT NULL,
  `leader` varchar(24) NOT NULL,
  `color` varchar(20) NOT NULL,
  `advert` varchar(50) NOT NULL,
  `deputy_rank` int(2) NOT NULL,
  `ranks_num` int(2) NOT NULL,
  `ranks` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Дамп данных таблицы `factions`
--

INSERT INTO `factions` (`id`, `name`, `leader`, `color`, `advert`, `deputy_rank`, `ranks_num`, `ranks`) VALUES
(1, 'LSPD', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(2, 'SFPD', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(3, 'LVPD', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(4, 'FBI', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(5, 'LS EMS', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(6, 'SF EMS', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(7, 'LV EMS', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(8, 'Groove', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(9, 'Ballas', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(10, 'Vagos', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(11, 'Aztecas', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(12, 'Yakuza', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(13, 'La Cosa Nostra', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(14, 'Russian Mafia', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия'),
(15, 'Triads', '', '', '', 0, 10, 'Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия,Без названия');

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(24) NOT NULL,
  `password` varchar(40) NOT NULL,
  `admin` int(1) NOT NULL,
  `admin_pass` varchar(24) NOT NULL,
  `money` int(11) NOT NULL,
  `bank` int(11) NOT NULL,
  `donate` int(11) NOT NULL,
  `phone` varchar(24) NOT NULL,
  `exp` int(255) NOT NULL,
  `lvl` int(5) NOT NULL,
  `hours` int(5) NOT NULL,
  `gender` int(1) NOT NULL,
  `skin` int(3) NOT NULL,
  `lastPosX` float NOT NULL,
  `lastPosY` float NOT NULL,
  `lastPosZ` float NOT NULL,
  `lastVW` int(11) NOT NULL,
  `lastInt` int(11) NOT NULL,
  `spawnPosX` float NOT NULL,
  `spawnPosY` float NOT NULL,
  `spawnPosZ` float NOT NULL,
  `spawnDegree` float NOT NULL,
  `city` varchar(2) NOT NULL,
  `last_time` int(255) NOT NULL,
  `warns` int(1) NOT NULL,
  `regip` varchar(16) NOT NULL,
  `lastip` varchar(16) NOT NULL,
  `referal` varchar(24) NOT NULL,
  `mail` varchar(50) NOT NULL,
  `wanted` int(3) NOT NULL,
  `vip` int(1) NOT NULL,
  `faction` int(2) NOT NULL,
  `rank` int(2) NOT NULL,
  `leader` int(1) NOT NULL,
  `job` int(2) NOT NULL,
  `hp` int(11) NOT NULL,
  `arm` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`id`, `name`, `password`, `admin`, `admin_pass`, `money`, `bank`, `donate`, `phone`, `exp`, `lvl`, `hours`, `gender`, `skin`, `lastPosX`, `lastPosY`, `lastPosZ`, `lastVW`, `lastInt`, `spawnPosX`, `spawnPosY`, `spawnPosZ`, `spawnDegree`, `city`, `last_time`, `warns`, `regip`, `lastip`, `referal`, `mail`, `wanted`, `vip`, `faction`, `rank`, `leader`, `job`, `hp`, `arm`) VALUES
(1, 'Alvaro_Hold', 'E10ADC3949BA59ABBE56E057F20F883E', 6, '88567', 100, 1000000, 8543, '2334678', 602, 12, 64, 1, 162, -2647.04, 1411.63, 906.273, 2147483646, 3, -1405.45, -312.193, 14.1484, 0, 'sf', 1654097824, 0, '127.0.0.1', '127.0.0.1', 'RaidziN', 'hold404@yandex.ru', 0, 0, 12, 10, 1, 2, 100, 0);

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `bans`
--
ALTER TABLE `bans`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `factions`
--
ALTER TABLE `factions`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `bans`
--
ALTER TABLE `bans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `factions`
--
ALTER TABLE `factions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
