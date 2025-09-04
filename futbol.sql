-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 04-09-2025 a las 06:19:35
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `futbol`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ActualizarMarcador` (IN `p_id_partido` VARCHAR(150), IN `p_goles_local` INT, IN `p_goles_visitante` INT)   BEGIN
    UPDATE partidos
    SET goles_local = p_goles_local,
        goles_visitante = p_goles_visitante
    WHERE id_partido = p_id_partido;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EliminarJugador` (IN `p_id_jugador` VARCHAR(15))   BEGIN
    DELETE FROM goles WHERE id_jugador = p_id_jugador;
    DELETE FROM jugadores WHERE id_jugador = p_id_jugador;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarArbitro` (IN `p_id_arbitro` VARCHAR(15), IN `p_nombre` VARCHAR(100), IN `p_nacionalidad` VARCHAR(50))   BEGIN
    IF NOT EXISTS (SELECT 1 FROM arbitros WHERE id_arbitro = p_id_arbitro) THEN
        INSERT INTO arbitros VALUES (p_id_arbitro, p_nombre, p_nacionalidad);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El árbitro ya existe';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarEquipo` (IN `p_id_equipo` VARCHAR(100), IN `p_ciudad` VARCHAR(50), IN `p_fundacion` INT, IN `p_liga` VARCHAR(100))   BEGIN
    IF NOT EXISTS (SELECT 1 FROM equipos WHERE id_equipo = p_id_equipo) THEN
        INSERT INTO equipos VALUES (p_id_equipo, p_ciudad, p_fundacion, p_liga);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El equipo ya existe';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarGol` (IN `p_id_partido` VARCHAR(150), IN `p_id_jugador` VARCHAR(15), IN `p_minuto` INT, IN `p_tipo` VARCHAR(20), IN `p_descripcion` VARCHAR(255))   BEGIN
    DECLARE v_id_gol VARCHAR(20);
    SET v_id_gol = CONCAT(LEFT(p_id_partido, 3), '_G', LPAD((SELECT COUNT(*)+1 FROM goles WHERE id_partido = p_id_partido), 2, '0'));

    INSERT INTO goles VALUES (v_id_gol, p_id_partido, p_id_jugador, p_minuto, p_tipo, p_descripcion);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarJugador` (IN `p_id_jugador` VARCHAR(15), IN `p_nombre` VARCHAR(100), IN `p_posicion` VARCHAR(30), IN `p_fecha_nacimiento` DATE, IN `p_nacionalidad` VARCHAR(50), IN `p_id_equipo` VARCHAR(100))   BEGIN
    IF NOT EXISTS (SELECT 1 FROM jugadores WHERE id_jugador = p_id_jugador) THEN
        INSERT INTO jugadores VALUES (p_id_jugador, p_nombre, p_posicion, p_fecha_nacimiento, p_nacionalidad, p_id_equipo);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El jugador ya existe';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarLiga` (IN `p_id_liga` VARCHAR(100), IN `p_pais` VARCHAR(50), IN `p_temporada` VARCHAR(10), IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE)   BEGIN
    IF NOT EXISTS (SELECT 1 FROM ligas WHERE id_liga = p_id_liga) THEN
        INSERT INTO ligas VALUES (p_id_liga, p_pais, p_temporada, p_fecha_inicio, p_fecha_fin);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La liga ya existe';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarPartido` (IN `p_fecha_hora` DATETIME, IN `p_estadio` VARCHAR(50), IN `p_id_equipo_local` VARCHAR(100), IN `p_id_equipo_visitante` VARCHAR(100), IN `p_goles_local` INT, IN `p_goles_visitante` INT, IN `p_jornada` INT, IN `p_id_liga` VARCHAR(100), IN `p_id_arbitro` VARCHAR(15), IN `p_estado` VARCHAR(20))   BEGIN
    DECLARE v_id_partido VARCHAR(150);
    SET v_id_partido = CONCAT(p_id_equipo_local, '_vs_', p_id_equipo_visitante, '_', DATE_FORMAT(p_fecha_hora, '%Y%m%d'));

    IF NOT EXISTS (SELECT 1 FROM partidos WHERE id_partido = v_id_partido) THEN
        INSERT INTO partidos VALUES (v_id_partido, p_fecha_hora, p_estadio, p_id_equipo_local, p_id_equipo_visitante,
                                     p_goles_local, p_goles_visitante, p_jornada, p_id_liga, p_id_arbitro, p_estado);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El partido ya existe';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ObtenerPosiciones` (IN `p_id_liga` VARCHAR(100))   BEGIN
    SELECT * FROM Vista_Posiciones
    WHERE liga = p_id_liga
    ORDER BY pts DESC, dg DESC, gf DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TransferirJugador` (IN `p_id_jugador` VARCHAR(15), IN `p_nuevo_equipo` VARCHAR(100))   BEGIN
    UPDATE jugadores
    SET id_equipo = p_nuevo_equipo
    WHERE id_jugador = p_id_jugador;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `arbitros`
--

CREATE TABLE `arbitros` (
  `id_arbitro` varchar(15) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `nacionalidad` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `arbitros`
--

INSERT INTO `arbitros` (`id_arbitro`, `nombre`, `nacionalidad`) VALUES
('CC2001', 'Andrés Rojas', 'Colombia'),
('CC2002', 'Fernando Rapallini', 'Argentina'),
('CC3001', 'Luis García', 'México');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipos`
--

CREATE TABLE `equipos` (
  `id_equipo` varchar(100) NOT NULL,
  `ciudad` varchar(50) DEFAULT NULL,
  `fundacion` int(11) DEFAULT NULL,
  `liga` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `equipos`
--

INSERT INTO `equipos` (`id_equipo`, `ciudad`, `fundacion`, `liga`) VALUES
('América', 'Ciudad de México', 1916, 'Liga Mexicana'),
('Atlético Nacional', 'Medellín', 1947, 'Liga Colombiana'),
('Boca Juniors', 'Buenos Aires', 1905, 'Liga Argentina'),
('Millonarios', 'Bogotá', 1946, 'Liga Colombiana');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `goles`
--

CREATE TABLE `goles` (
  `id_gol` varchar(20) NOT NULL,
  `id_partido` varchar(150) NOT NULL,
  `id_jugador` varchar(15) NOT NULL,
  `minuto` int(11) DEFAULT NULL,
  `tipo` varchar(20) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `goles`
--

INSERT INTO `goles` (`id_gol`, `id_partido`, `id_jugador`, `minuto`, `tipo`, `descripcion`) VALUES
('P1_G1', 'Atlético Nacional_vs_Millonarios_20250301', 'CC1001', 23, 'Cabeza', 'Gol de cabeza en tiro de esquina'),
('P1_G2', 'Atlético Nacional_vs_Millonarios_20250301', 'CC1002', 45, 'Penal', 'Gol de penal'),
('P2_G1', 'Boca Juniors_vs_Atlético Nacional_20250305', 'CC1003', 78, 'Tiro Libre', 'Gol de tiro libre');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `jugadores`
--

CREATE TABLE `jugadores` (
  `id_jugador` varchar(15) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `posicion` varchar(30) DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `nacionalidad` varchar(50) DEFAULT NULL,
  `id_equipo` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `jugadores`
--

INSERT INTO `jugadores` (`id_jugador`, `nombre`, `posicion`, `fecha_nacimiento`, `nacionalidad`, `id_equipo`) VALUES
('CC1001', 'Juan Pérez', 'Delantero', '1995-03-12', 'Colombia', 'Atlético Nacional'),
('CC1002', 'Carlos Gómez', 'Portero', '1990-07-25', 'Colombia', 'Millonarios'),
('CC1003', 'Luis Martínez', 'Defensa', '1998-11-05', 'Argentina', 'Boca Juniors');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ligas`
--

CREATE TABLE `ligas` (
  `id_liga` varchar(100) NOT NULL,
  `pais` varchar(50) NOT NULL,
  `temporada` varchar(10) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ligas`
--

INSERT INTO `ligas` (`id_liga`, `pais`, `temporada`, `fecha_inicio`, `fecha_fin`) VALUES
('Liga Argentina', 'Argentina', '2025', '2025-02-01', '2025-07-15'),
('Liga Colombiana', 'Colombia', '2025', '2025-01-15', '2025-06-30'),
('Liga Mexicana', 'México', '2025', '2025-01-10', '2025-06-20');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partidos`
--

CREATE TABLE `partidos` (
  `id_partido` varchar(150) NOT NULL,
  `fecha_hora` datetime NOT NULL,
  `estadio` varchar(50) DEFAULT NULL,
  `id_equipo_local` varchar(100) NOT NULL,
  `id_equipo_visitante` varchar(100) NOT NULL,
  `goles_local` int(11) DEFAULT NULL,
  `goles_visitante` int(11) DEFAULT NULL,
  `jornada` int(11) DEFAULT NULL,
  `id_liga` varchar(100) NOT NULL,
  `id_arbitro` varchar(15) DEFAULT NULL,
  `estado` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `partidos`
--

INSERT INTO `partidos` (`id_partido`, `fecha_hora`, `estadio`, `id_equipo_local`, `id_equipo_visitante`, `goles_local`, `goles_visitante`, `jornada`, `id_liga`, `id_arbitro`, `estado`) VALUES
('América_vs_Boca Juniors_20250310', '2025-03-10 20:00:00', 'Estadio Azteca', 'América', 'Boca Juniors', 1, 0, 1, 'Liga Mexicana', 'CC3001', 'Pendiente'),
('Atlético Nacional_vs_Millonarios_20250301', '2025-03-01 15:30:00', 'Atanasio Girardot', 'Atlético Nacional', 'Millonarios', 2, 1, 1, 'Liga Colombiana', 'CC2001', 'Finalizado'),
('Boca Juniors_vs_Atlético Nacional_20250305', '2025-03-05 18:00:00', 'La Bombonera', 'Boca Juniors', 'Atlético Nacional', 1, 1, 2, 'Liga Argentina', 'CC2002', 'Finalizado');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_arbitros_designaciones`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_arbitros_designaciones` (
`cedula_arbitro` varchar(15)
,`arbitro` varchar(100)
,`partidos_dirigidos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_arbitros_internacionales`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_arbitros_internacionales` (
`cedula_arbitro` varchar(15)
,`nombre` varchar(100)
,`nacionalidad` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_arbitros_partidos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_arbitros_partidos` (
`id_partido` varchar(150)
,`fecha_hora` datetime
,`liga` varchar(100)
,`equipo_local` varchar(100)
,`equipo_visitante` varchar(100)
,`goles_local` int(11)
,`goles_visitante` int(11)
,`cedula_arbitro` varchar(15)
,`arbitro` varchar(100)
,`estado` varchar(20)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_edad_jugadores`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_edad_jugadores` (
`cedula_jugador` varchar(15)
,`jugador` varchar(100)
,`equipo` varchar(100)
,`edad` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_equipos_antiguos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_equipos_antiguos` (
`nombre` varchar(100)
,`ciudad` varchar(50)
,`fundacion` int(11)
,`liga` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_fixture`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_fixture` (
`liga` varchar(100)
,`jornada` int(11)
,`fecha_hora` datetime
,`equipo_local` varchar(100)
,`equipo_visitante` varchar(100)
,`marcador` varchar(23)
,`estado` varchar(20)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_goleadores`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_goleadores` (
`cedula_jugador` varchar(15)
,`jugador` varchar(100)
,`equipo` varchar(100)
,`goles` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_goleadores_por_liga`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_goleadores_por_liga` (
`liga` varchar(100)
,`cedula_jugador` varchar(15)
,`jugador` varchar(100)
,`equipo` varchar(100)
,`goles` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_goles_detalle`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_goles_detalle` (
`id_gol` varchar(20)
,`id_partido` varchar(150)
,`fecha_hora` datetime
,`liga` varchar(100)
,`minuto` int(11)
,`tipo` varchar(20)
,`descripcion` varchar(255)
,`cedula_jugador` varchar(15)
,`jugador` varchar(100)
,`equipo_jugador` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_goles_por_partido`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_goles_por_partido` (
`id_partido` varchar(150)
,`total_goles` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_jugadores_extranjeros`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_jugadores_extranjeros` (
`cedula_jugador` varchar(15)
,`nombre` varchar(100)
,`nacionalidad` varchar(50)
,`equipo` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_jugadores_mayores_30`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_jugadores_mayores_30` (
`cedula_jugador` varchar(15)
,`nombre` varchar(100)
,`id_equipo` varchar(100)
,`edad` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_jugadores_menores_20`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_jugadores_menores_20` (
`cedula_jugador` varchar(15)
,`nombre` varchar(100)
,`id_equipo` varchar(100)
,`edad` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_jugadores_por_equipo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_jugadores_por_equipo` (
`equipo` varchar(100)
,`cantidad_jugadores` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_jugadores_por_liga`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_jugadores_por_liga` (
`liga` varchar(100)
,`total_jugadores` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ligas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ligas` (
`liga` varchar(100)
,`pais` varchar(50)
,`temporada` varchar(10)
,`equipos_participantes` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_maximos_anotadores`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_maximos_anotadores` (
`cedula_jugador` varchar(15)
,`nombre` varchar(100)
,`equipo` varchar(100)
,`total_goles` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_partidos_con_mas_goles`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_partidos_con_mas_goles` (
`id_partido` varchar(150)
,`total_goles` bigint(12)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_partidos_detalle`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_partidos_detalle` (
`id_partido` varchar(150)
,`fecha_hora` datetime
,`estadio` varchar(50)
,`equipo_local` varchar(100)
,`equipo_visitante` varchar(100)
,`goles_local` int(11)
,`goles_visitante` int(11)
,`jornada` int(11)
,`liga` varchar(100)
,`arbitro` varchar(100)
,`estado` varchar(20)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_partidos_por_equipo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_partidos_por_equipo` (
`id_partido` varchar(150)
,`fecha_hora` datetime
,`estadio` varchar(50)
,`liga` varchar(100)
,`jornada` int(11)
,`condicion` varchar(9)
,`equipo` varchar(100)
,`rival` varchar(100)
,`goles_favor` int(11)
,`goles_contra` int(11)
,`estado` varchar(20)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_partidos_por_jornada`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_partidos_por_jornada` (
`id_liga` varchar(100)
,`jornada` int(11)
,`cantidad_partidos` bigint(21)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_partidos_sin_goles`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_partidos_sin_goles` (
`id_partido` varchar(150)
,`id_equipo_local` varchar(100)
,`id_equipo_visitante` varchar(100)
,`fecha_hora` datetime
,`id_liga` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_posiciones`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_posiciones` (
`liga` varchar(100)
,`equipo` varchar(100)
,`pj` decimal(32,0)
,`pg` decimal(32,0)
,`pe` decimal(32,0)
,`pp` decimal(32,0)
,`gf` decimal(32,0)
,`gc` decimal(32,0)
,`dg` decimal(33,0)
,`pts` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_promedio_goles_partido`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_promedio_goles_partido` (
`id_partido` varchar(150)
,`equipo_local` varchar(100)
,`equipo_visitante` varchar(100)
,`promedio_goles` decimal(15,4)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_resultados_por_liga`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_resultados_por_liga` (
`liga` varchar(100)
,`partidos_jugados` bigint(21)
,`victorias_local` decimal(22,0)
,`victorias_visitante` decimal(22,0)
,`empates` decimal(22,0)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_arbitros_designaciones`
--
DROP TABLE IF EXISTS `vista_arbitros_designaciones`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_arbitros_designaciones`  AS SELECT `a`.`id_arbitro` AS `cedula_arbitro`, `a`.`nombre` AS `arbitro`, count(`p`.`id_partido`) AS `partidos_dirigidos` FROM (`arbitros` `a` left join `partidos` `p` on(`p`.`id_arbitro` = `a`.`id_arbitro`)) GROUP BY `a`.`id_arbitro`, `a`.`nombre` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_arbitros_internacionales`
--
DROP TABLE IF EXISTS `vista_arbitros_internacionales`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_arbitros_internacionales`  AS SELECT `a`.`id_arbitro` AS `cedula_arbitro`, `a`.`nombre` AS `nombre`, `a`.`nacionalidad` AS `nacionalidad` FROM `arbitros` AS `a` WHERE `a`.`nacionalidad` <> 'Colombia' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_arbitros_partidos`
--
DROP TABLE IF EXISTS `vista_arbitros_partidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_arbitros_partidos`  AS SELECT `p`.`id_partido` AS `id_partido`, `p`.`fecha_hora` AS `fecha_hora`, `p`.`id_liga` AS `liga`, `p`.`id_equipo_local` AS `equipo_local`, `p`.`id_equipo_visitante` AS `equipo_visitante`, `p`.`goles_local` AS `goles_local`, `p`.`goles_visitante` AS `goles_visitante`, `a`.`id_arbitro` AS `cedula_arbitro`, `a`.`nombre` AS `arbitro`, `p`.`estado` AS `estado` FROM (`partidos` `p` join `arbitros` `a` on(`a`.`id_arbitro` = `p`.`id_arbitro`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_edad_jugadores`
--
DROP TABLE IF EXISTS `vista_edad_jugadores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_edad_jugadores`  AS SELECT `j`.`id_jugador` AS `cedula_jugador`, `j`.`nombre` AS `jugador`, `j`.`id_equipo` AS `equipo`, timestampdiff(YEAR,`j`.`fecha_nacimiento`,curdate()) AS `edad` FROM `jugadores` AS `j` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_equipos_antiguos`
--
DROP TABLE IF EXISTS `vista_equipos_antiguos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_equipos_antiguos`  AS SELECT `equipos`.`id_equipo` AS `nombre`, `equipos`.`ciudad` AS `ciudad`, `equipos`.`fundacion` AS `fundacion`, `equipos`.`liga` AS `liga` FROM `equipos` WHERE `equipos`.`fundacion` < 1980 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_fixture`
--
DROP TABLE IF EXISTS `vista_fixture`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_fixture`  AS SELECT `p`.`id_liga` AS `liga`, `p`.`jornada` AS `jornada`, `p`.`fecha_hora` AS `fecha_hora`, `p`.`id_equipo_local` AS `equipo_local`, `p`.`id_equipo_visitante` AS `equipo_visitante`, concat(coalesce(`p`.`goles_local`,''),case when `p`.`goles_local` is null then '' else '-' end,coalesce(`p`.`goles_visitante`,'')) AS `marcador`, `p`.`estado` AS `estado` FROM `partidos` AS `p` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_goleadores`
--
DROP TABLE IF EXISTS `vista_goleadores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_goleadores`  AS SELECT `j`.`id_jugador` AS `cedula_jugador`, `j`.`nombre` AS `jugador`, `j`.`id_equipo` AS `equipo`, count(0) AS `goles` FROM (`goles` `g` join `jugadores` `j` on(`j`.`id_jugador` = `g`.`id_jugador`)) GROUP BY `j`.`id_jugador`, `j`.`nombre`, `j`.`id_equipo` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_goleadores_por_liga`
--
DROP TABLE IF EXISTS `vista_goleadores_por_liga`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_goleadores_por_liga`  AS SELECT `p`.`id_liga` AS `liga`, `j`.`id_jugador` AS `cedula_jugador`, `j`.`nombre` AS `jugador`, `j`.`id_equipo` AS `equipo`, count(0) AS `goles` FROM ((`goles` `g` join `partidos` `p` on(`p`.`id_partido` = `g`.`id_partido`)) join `jugadores` `j` on(`j`.`id_jugador` = `g`.`id_jugador`)) GROUP BY `p`.`id_liga`, `j`.`id_jugador`, `j`.`nombre`, `j`.`id_equipo` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_goles_detalle`
--
DROP TABLE IF EXISTS `vista_goles_detalle`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_goles_detalle`  AS SELECT `g`.`id_gol` AS `id_gol`, `g`.`id_partido` AS `id_partido`, `p`.`fecha_hora` AS `fecha_hora`, `p`.`id_liga` AS `liga`, `g`.`minuto` AS `minuto`, `g`.`tipo` AS `tipo`, `g`.`descripcion` AS `descripcion`, `j`.`id_jugador` AS `cedula_jugador`, `j`.`nombre` AS `jugador`, `j`.`id_equipo` AS `equipo_jugador` FROM ((`goles` `g` join `partidos` `p` on(`p`.`id_partido` = `g`.`id_partido`)) join `jugadores` `j` on(`j`.`id_jugador` = `g`.`id_jugador`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_goles_por_partido`
--
DROP TABLE IF EXISTS `vista_goles_por_partido`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_goles_por_partido`  AS SELECT `p`.`id_partido` AS `id_partido`, count(`g`.`id_gol`) AS `total_goles` FROM (`partidos` `p` left join `goles` `g` on(`g`.`id_partido` = `p`.`id_partido`)) GROUP BY `p`.`id_partido` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_jugadores_extranjeros`
--
DROP TABLE IF EXISTS `vista_jugadores_extranjeros`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_jugadores_extranjeros`  AS SELECT `j`.`id_jugador` AS `cedula_jugador`, `j`.`nombre` AS `nombre`, `j`.`nacionalidad` AS `nacionalidad`, `j`.`id_equipo` AS `equipo` FROM ((`jugadores` `j` join `equipos` `e` on(`e`.`id_equipo` = `j`.`id_equipo`)) join `ligas` `l` on(`l`.`id_liga` = `e`.`liga`)) WHERE `j`.`nacionalidad` <> `l`.`pais` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_jugadores_mayores_30`
--
DROP TABLE IF EXISTS `vista_jugadores_mayores_30`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_jugadores_mayores_30`  AS SELECT `j`.`id_jugador` AS `cedula_jugador`, `j`.`nombre` AS `nombre`, `j`.`id_equipo` AS `id_equipo`, timestampdiff(YEAR,`j`.`fecha_nacimiento`,curdate()) AS `edad` FROM `jugadores` AS `j` WHERE timestampdiff(YEAR,`j`.`fecha_nacimiento`,curdate()) > 30 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_jugadores_menores_20`
--
DROP TABLE IF EXISTS `vista_jugadores_menores_20`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_jugadores_menores_20`  AS SELECT `j`.`id_jugador` AS `cedula_jugador`, `j`.`nombre` AS `nombre`, `j`.`id_equipo` AS `id_equipo`, timestampdiff(YEAR,`j`.`fecha_nacimiento`,curdate()) AS `edad` FROM `jugadores` AS `j` WHERE timestampdiff(YEAR,`j`.`fecha_nacimiento`,curdate()) < 20 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_jugadores_por_equipo`
--
DROP TABLE IF EXISTS `vista_jugadores_por_equipo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_jugadores_por_equipo`  AS SELECT `e`.`id_equipo` AS `equipo`, count(`j`.`id_jugador`) AS `cantidad_jugadores` FROM (`equipos` `e` left join `jugadores` `j` on(`j`.`id_equipo` = `e`.`id_equipo`)) GROUP BY `e`.`id_equipo` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_jugadores_por_liga`
--
DROP TABLE IF EXISTS `vista_jugadores_por_liga`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_jugadores_por_liga`  AS SELECT `l`.`id_liga` AS `liga`, count(`j`.`id_jugador`) AS `total_jugadores` FROM ((`ligas` `l` join `equipos` `e` on(`e`.`liga` = `l`.`id_liga`)) join `jugadores` `j` on(`j`.`id_equipo` = `e`.`id_equipo`)) GROUP BY `l`.`id_liga` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ligas`
--
DROP TABLE IF EXISTS `vista_ligas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ligas`  AS SELECT `l`.`id_liga` AS `liga`, `l`.`pais` AS `pais`, `l`.`temporada` AS `temporada`, count(`e`.`id_equipo`) AS `equipos_participantes` FROM (`ligas` `l` left join `equipos` `e` on(`e`.`liga` = `l`.`id_liga`)) GROUP BY `l`.`id_liga`, `l`.`pais`, `l`.`temporada` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_maximos_anotadores`
--
DROP TABLE IF EXISTS `vista_maximos_anotadores`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_maximos_anotadores`  AS SELECT `j`.`id_jugador` AS `cedula_jugador`, `j`.`nombre` AS `nombre`, `j`.`id_equipo` AS `equipo`, count(`g`.`id_gol`) AS `total_goles` FROM (`jugadores` `j` join `goles` `g` on(`g`.`id_jugador` = `j`.`id_jugador`)) GROUP BY `j`.`id_jugador`, `j`.`nombre`, `j`.`id_equipo` ORDER BY count(`g`.`id_gol`) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_partidos_con_mas_goles`
--
DROP TABLE IF EXISTS `vista_partidos_con_mas_goles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_partidos_con_mas_goles`  AS SELECT `p`.`id_partido` AS `id_partido`, coalesce(`p`.`goles_local`,0) + coalesce(`p`.`goles_visitante`,0) AS `total_goles` FROM `partidos` AS `p` ORDER BY coalesce(`p`.`goles_local`,0) + coalesce(`p`.`goles_visitante`,0) DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_partidos_detalle`
--
DROP TABLE IF EXISTS `vista_partidos_detalle`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_partidos_detalle`  AS SELECT `p`.`id_partido` AS `id_partido`, `p`.`fecha_hora` AS `fecha_hora`, `p`.`estadio` AS `estadio`, `p`.`id_equipo_local` AS `equipo_local`, `p`.`id_equipo_visitante` AS `equipo_visitante`, `p`.`goles_local` AS `goles_local`, `p`.`goles_visitante` AS `goles_visitante`, `p`.`jornada` AS `jornada`, `p`.`id_liga` AS `liga`, `a`.`nombre` AS `arbitro`, `p`.`estado` AS `estado` FROM (`partidos` `p` left join `arbitros` `a` on(`a`.`id_arbitro` = `p`.`id_arbitro`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_partidos_por_equipo`
--
DROP TABLE IF EXISTS `vista_partidos_por_equipo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_partidos_por_equipo`  AS SELECT `p`.`id_partido` AS `id_partido`, `p`.`fecha_hora` AS `fecha_hora`, `p`.`estadio` AS `estadio`, `p`.`id_liga` AS `liga`, `p`.`jornada` AS `jornada`, 'Local' AS `condicion`, `p`.`id_equipo_local` AS `equipo`, `p`.`id_equipo_visitante` AS `rival`, `p`.`goles_local` AS `goles_favor`, `p`.`goles_visitante` AS `goles_contra`, `p`.`estado` AS `estado` FROM `partidos` AS `p`union all select `p`.`id_partido` AS `id_partido`,`p`.`fecha_hora` AS `fecha_hora`,`p`.`estadio` AS `estadio`,`p`.`id_liga` AS `id_liga`,`p`.`jornada` AS `jornada`,'Visitante' AS `Visitante`,`p`.`id_equipo_visitante` AS `id_equipo_visitante`,`p`.`id_equipo_local` AS `id_equipo_local`,`p`.`goles_visitante` AS `goles_visitante`,`p`.`goles_local` AS `goles_local`,`p`.`estado` AS `estado` from `partidos` `p`  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_partidos_por_jornada`
--
DROP TABLE IF EXISTS `vista_partidos_por_jornada`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_partidos_por_jornada`  AS SELECT `p`.`id_liga` AS `id_liga`, `p`.`jornada` AS `jornada`, count(0) AS `cantidad_partidos` FROM `partidos` AS `p` GROUP BY `p`.`id_liga`, `p`.`jornada` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_partidos_sin_goles`
--
DROP TABLE IF EXISTS `vista_partidos_sin_goles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_partidos_sin_goles`  AS SELECT `p`.`id_partido` AS `id_partido`, `p`.`id_equipo_local` AS `id_equipo_local`, `p`.`id_equipo_visitante` AS `id_equipo_visitante`, `p`.`fecha_hora` AS `fecha_hora`, `p`.`id_liga` AS `id_liga` FROM `partidos` AS `p` WHERE coalesce(`p`.`goles_local`,0) = 0 AND coalesce(`p`.`goles_visitante`,0) = 0 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_posiciones`
--
DROP TABLE IF EXISTS `vista_posiciones`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_posiciones`  AS SELECT `t`.`liga` AS `liga`, `t`.`equipo` AS `equipo`, sum(`t`.`pj`) AS `pj`, sum(`t`.`pg`) AS `pg`, sum(`t`.`pe`) AS `pe`, sum(`t`.`pp`) AS `pp`, sum(`t`.`gf`) AS `gf`, sum(`t`.`gc`) AS `gc`, sum(`t`.`gf`) - sum(`t`.`gc`) AS `dg`, sum(`t`.`pts`) AS `pts` FROM (select `p`.`id_liga` AS `liga`,`p`.`id_equipo_local` AS `equipo`,1 AS `pj`,case when `p`.`goles_local` > `p`.`goles_visitante` then 1 else 0 end AS `pg`,case when `p`.`goles_local` = `p`.`goles_visitante` then 1 else 0 end AS `pe`,case when `p`.`goles_local` < `p`.`goles_visitante` then 1 else 0 end AS `pp`,`p`.`goles_local` AS `gf`,`p`.`goles_visitante` AS `gc`,case when `p`.`goles_local` > `p`.`goles_visitante` then 3 when `p`.`goles_local` = `p`.`goles_visitante` then 1 else 0 end AS `pts` from `partidos` `p` where `p`.`estado` = 'Finalizado' union all select `p`.`id_liga` AS `id_liga`,`p`.`id_equipo_visitante` AS `id_equipo_visitante`,1 AS `1`,case when `p`.`goles_visitante` > `p`.`goles_local` then 1 else 0 end AS `CASE WHEN p.goles_visitante > p.goles_local THEN 1 ELSE 0 END`,case when `p`.`goles_visitante` = `p`.`goles_local` then 1 else 0 end AS `CASE WHEN p.goles_visitante = p.goles_local THEN 1 ELSE 0 END`,case when `p`.`goles_visitante` < `p`.`goles_local` then 1 else 0 end AS `CASE WHEN p.goles_visitante < p.goles_local THEN 1 ELSE 0 END`,`p`.`goles_visitante` AS `goles_visitante`,`p`.`goles_local` AS `goles_local`,case when `p`.`goles_visitante` > `p`.`goles_local` then 3 when `p`.`goles_visitante` = `p`.`goles_local` then 1 else 0 end from `partidos` `p` where `p`.`estado` = 'Finalizado') AS `t` GROUP BY `t`.`liga`, `t`.`equipo` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_promedio_goles_partido`
--
DROP TABLE IF EXISTS `vista_promedio_goles_partido`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_promedio_goles_partido`  AS SELECT `p`.`id_partido` AS `id_partido`, `p`.`id_equipo_local` AS `equipo_local`, `p`.`id_equipo_visitante` AS `equipo_visitante`, (coalesce(`p`.`goles_local`,0) + coalesce(`p`.`goles_visitante`,0)) / 2 AS `promedio_goles` FROM `partidos` AS `p` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_resultados_por_liga`
--
DROP TABLE IF EXISTS `vista_resultados_por_liga`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_resultados_por_liga`  AS SELECT `p`.`id_liga` AS `liga`, count(0) AS `partidos_jugados`, sum(case when `p`.`goles_local` > `p`.`goles_visitante` then 1 else 0 end) AS `victorias_local`, sum(case when `p`.`goles_local` < `p`.`goles_visitante` then 1 else 0 end) AS `victorias_visitante`, sum(case when `p`.`goles_local` = `p`.`goles_visitante` then 1 else 0 end) AS `empates` FROM `partidos` AS `p` GROUP BY `p`.`id_liga` ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `arbitros`
--
ALTER TABLE `arbitros`
  ADD PRIMARY KEY (`id_arbitro`);

--
-- Indices de la tabla `equipos`
--
ALTER TABLE `equipos`
  ADD PRIMARY KEY (`id_equipo`),
  ADD KEY `liga` (`liga`);

--
-- Indices de la tabla `goles`
--
ALTER TABLE `goles`
  ADD PRIMARY KEY (`id_gol`),
  ADD KEY `id_partido` (`id_partido`),
  ADD KEY `id_jugador` (`id_jugador`);

--
-- Indices de la tabla `jugadores`
--
ALTER TABLE `jugadores`
  ADD PRIMARY KEY (`id_jugador`),
  ADD KEY `id_equipo` (`id_equipo`);

--
-- Indices de la tabla `ligas`
--
ALTER TABLE `ligas`
  ADD PRIMARY KEY (`id_liga`);

--
-- Indices de la tabla `partidos`
--
ALTER TABLE `partidos`
  ADD PRIMARY KEY (`id_partido`),
  ADD KEY `id_equipo_local` (`id_equipo_local`),
  ADD KEY `id_equipo_visitante` (`id_equipo_visitante`),
  ADD KEY `id_liga` (`id_liga`),
  ADD KEY `id_arbitro` (`id_arbitro`);

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `equipos`
--
ALTER TABLE `equipos`
  ADD CONSTRAINT `equipos_ibfk_1` FOREIGN KEY (`liga`) REFERENCES `ligas` (`id_liga`);

--
-- Filtros para la tabla `goles`
--
ALTER TABLE `goles`
  ADD CONSTRAINT `goles_ibfk_1` FOREIGN KEY (`id_partido`) REFERENCES `partidos` (`id_partido`),
  ADD CONSTRAINT `goles_ibfk_2` FOREIGN KEY (`id_jugador`) REFERENCES `jugadores` (`id_jugador`);

--
-- Filtros para la tabla `jugadores`
--
ALTER TABLE `jugadores`
  ADD CONSTRAINT `jugadores_ibfk_1` FOREIGN KEY (`id_equipo`) REFERENCES `equipos` (`id_equipo`);

--
-- Filtros para la tabla `partidos`
--
ALTER TABLE `partidos`
  ADD CONSTRAINT `partidos_ibfk_1` FOREIGN KEY (`id_equipo_local`) REFERENCES `equipos` (`id_equipo`),
  ADD CONSTRAINT `partidos_ibfk_2` FOREIGN KEY (`id_equipo_visitante`) REFERENCES `equipos` (`id_equipo`),
  ADD CONSTRAINT `partidos_ibfk_3` FOREIGN KEY (`id_liga`) REFERENCES `ligas` (`id_liga`),
  ADD CONSTRAINT `partidos_ibfk_4` FOREIGN KEY (`id_arbitro`) REFERENCES `arbitros` (`id_arbitro`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
