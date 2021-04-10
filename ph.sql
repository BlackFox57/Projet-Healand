-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le :  sam. 10 avr. 2021 à 21:02
-- Version du serveur :  10.4.10-MariaDB
-- Version de PHP :  7.3.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données :  `ph`
--

-- --------------------------------------------------------

--
-- Structure de la table `comptes`
--

CREATE TABLE `comptes` (
  `ec_ID` int(11) NOT NULL,
  `ec_IP` varchar(16) NOT NULL,
  `ec_Password` varchar(512) NOT NULL,
  `ec_Name` varchar(25) NOT NULL,
  `ec_Tutorial` int(11) NOT NULL,
  `ec_AutoConnect` int(11) NOT NULL,
  `ec_AdminLvl` int(11) NOT NULL,
  `ec_WhiteList` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `comptes`
--

INSERT INTO `comptes` (`ec_ID`, `ec_IP`, `ec_Password`, `ec_Name`, `ec_Tutorial`, `ec_AutoConnect`, `ec_AdminLvl`, `ec_WhiteList`) VALUES
(1, '127.0.0.1', 'D94D5B1D87E9C0A3F71DB93B9D05988B', 'Blackfox', 0, 0, 1, 1),
(2, '77.150.208.196', 'e10adc3949ba59abbe56e057f20f883e', 'Arsen_Gonzales', 0, 0, 0, 1);

-- --------------------------------------------------------

--
-- Structure de la table `personnages`
--

CREATE TABLE `personnages` (
  `ep_ID` int(11) NOT NULL,
  `ep_CompteID` int(11) NOT NULL,
  `ep_Nom` varchar(16) NOT NULL,
  `ep_Prenom` varchar(16) NOT NULL,
  `ep_Sexe` int(11) NOT NULL,
  `ep_Skin` int(11) NOT NULL,
  `ep_Age` int(11) NOT NULL,
  `ep_Ethnie` int(11) NOT NULL,
  `ep_Money` int(11) NOT NULL,
  `ep_Job` int(11) NOT NULL,
  `ep_PosX` float NOT NULL,
  `ep_PosY` float NOT NULL,
  `ep_PosZ` float NOT NULL,
  `ep_Rot` float NOT NULL,
  `ep_Interior` int(11) NOT NULL,
  `ep_Monde` int(11) NOT NULL,
  `ep_Created` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `personnages`
--

INSERT INTO `personnages` (`ep_ID`, `ep_CompteID`, `ep_Nom`, `ep_Prenom`, `ep_Sexe`, `ep_Skin`, `ep_Age`, `ep_Ethnie`, `ep_Money`, `ep_Job`, `ep_PosX`, `ep_PosY`, `ep_PosZ`, `ep_Rot`, `ep_Interior`, `ep_Monde`, `ep_Created`) VALUES
(1, 1, 'Benzaid', 'Yathif', 0, 21, 30, 0, 350, 0, 1787.7, -1861.95, 13.577, 92.122, 0, 0, 1),
(2, 2, 'Gonzales', 'Arseen', 0, 72, 31, 3, 350, 0, 1726.89, -1859.4, 13.414, 270.512, 0, 0, 1);

-- --------------------------------------------------------

--
-- Structure de la table `vehicles`
--

CREATE TABLE `vehicles` (
  `ev_ID` int(11) NOT NULL,
  `ev_ParamsID` int(11) NOT NULL,
  `ev_PersoID` int(11) NOT NULL,
  `ev_ColorA` int(11) NOT NULL,
  `ev_ColorB` int(11) NOT NULL,
  `ev_Etat` float NOT NULL,
  `ev_PosX` float NOT NULL,
  `ev_PosY` float NOT NULL,
  `ev_PosZ` float NOT NULL,
  `ev_Rot` float NOT NULL,
  `ev_Suppr` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `vparams`
--

CREATE TABLE `vparams` (
  `evp_ID` int(11) NOT NULL,
  `evp_Model` int(11) NOT NULL,
  `evp_Name` varchar(32) NOT NULL,
  `evp_Price` int(11) NOT NULL,
  `evp_MaxFuel` float NOT NULL,
  `evp_Suppr` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `vparams`
--

INSERT INTO `vparams` (`evp_ID`, `evp_Model`, `evp_Name`, `evp_Price`, `evp_MaxFuel`, `evp_Suppr`) VALUES
(1, 400, 'Landstalker', 50000, 80, 0),
(2, 401, 'Bravura', 12000, 40, 0),
(3, 402, 'Buffalo', 45000, 40, 0),
(4, 403, 'Linerunner', 160000, 120, 0),
(5, 404, 'Perenail', 9000, 70, 0),
(6, 405, 'Sentinel', 35000, 60, 0),
(7, 406, 'Dumper', 210000, 120, 0),
(8, 407, 'Firetruck', 250000, 80, 0),
(9, 408, 'Trashmaster', 45000, 80, 0),
(10, 409, 'Stretch', 140000, 60, 0),
(11, 410, 'Manana', 11000, 40, 0),
(12, 411, 'Infernus', 200000, 30, 0),
(13, 412, 'Voodoo', 9000, 60, 0),
(14, 413, 'Pony', 16000, 60, 0),
(15, 414, 'Mule', 13500, 80, 0),
(16, 415, 'Cheetah', 180000, 40, 0);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `comptes`
--
ALTER TABLE `comptes`
  ADD PRIMARY KEY (`ec_ID`);

--
-- Index pour la table `personnages`
--
ALTER TABLE `personnages`
  ADD PRIMARY KEY (`ep_ID`);

--
-- Index pour la table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`ev_ID`);

--
-- Index pour la table `vparams`
--
ALTER TABLE `vparams`
  ADD PRIMARY KEY (`evp_ID`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `comptes`
--
ALTER TABLE `comptes`
  MODIFY `ec_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `personnages`
--
ALTER TABLE `personnages`
  MODIFY `ep_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `ev_ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `vparams`
--
ALTER TABLE `vparams`
  MODIFY `evp_ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
