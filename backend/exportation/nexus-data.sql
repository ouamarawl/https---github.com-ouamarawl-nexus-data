-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : dim. 02 mars 2025 à 12:52
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `nexus-data`
--

-- --------------------------------------------------------

--
-- Structure de la table `admin_membre`
--

CREATE TABLE `admin_membre` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `admin_membre`
--

INSERT INTO `admin_membre` (`id`, `name`, `email`, `password`) VALUES
(29, 'wail ouamara', 'ouamara.wail8@gmail.com', 'Password'),
(31, 'mohamedamine', 'mohamedamine123076@gmail.com', 'amine2005'),
(43, 'soltana farid', 'faridsoltana@gmail.com', 'faridfarid');

-- --------------------------------------------------------

--
-- Structure de la table `commandes`
--

CREATE TABLE `commandes` (
  `id` int(11) NOT NULL,
  `nom` varchar(50) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `numero` varchar(15) NOT NULL,
  `produit` varchar(100) NOT NULL,
  `prix_total` decimal(10,2) NOT NULL,
  `date_commande` date NOT NULL,
  `lieu` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `commandes`
--

INSERT INTO `commandes` (`id`, `nom`, `prenom`, `email`, `numero`, `produit`, `prix_total`, `date_commande`, `lieu`) VALUES
(1, 'Ali', 'Bencheikh', 'ali@example.com', '+213550112233', 'PC Portable HP 15s', 75000.00, '2025-02-24', 'Alger, Rue Didouche Mourad'),
(2, 'teste', 'teste', 'ouazmara.wail8@gmail.com', '6666', 'Commande personnalisée', 4500.00, '2025-02-24', 'teste'),
(3, 'teste2', 'teste2', 'teste@gmail.com', '2222', 'Commande personnalisée', 4500.00, '2025-02-24', 'teste 2'),
(4, 'teste', 'tsteeee', 'aaaaaaaaaaaa@gmail.com', '2222', 'Commande personnalisée', 4500.00, '2025-02-25', 'zzzz'),
(5, 'OUAMARA', 'WAIL', 'teste@gmail.com', '999999999999999', 'Commande personnalisée', 4500.00, '2025-02-28', '10 Boulevard Joseph Vallier'),
(6, 'soltana', 'farid', 'farid@gmail.com', '222222', 'Commande personnalisée', 4500.00, '2025-03-02', '1600 sebala');

-- --------------------------------------------------------

--
-- Structure de la table `info_admin`
--

CREATE TABLE `info_admin` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `role` varchar(50) NOT NULL,
  `telephone` varchar(20) NOT NULL,
  `adresse` text DEFAULT NULL,
  `date_inscription` date DEFAULT curdate(),
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `info_admin`
--

INSERT INTO `info_admin` (`id`, `nom`, `email`, `role`, `telephone`, `adresse`, `date_inscription`, `password`) VALUES
(1, 'Jane Smith', 'janesmith@example.com', 'Modérateur', '0987654321', 'Oran, Algérie', '2023-12-10', 'fffff'),
(2, 'teste', 'teste@gmail.com', 'teste', '2222', 'AAAA', '2025-02-27', 'teste'),
(3, 'wail ouamara', 'ouamara.wail8@gmail.com', 'prprietéres ', '0549255042', '10 Boulevard Joseph Vallier', '2025-02-25', 'wail123'),
(7, 'omar', 'omar@gmail.com', 'teste', '0549255042', '10 Boulevard Joseph Vallier', '2025-02-06', 'teste'),
(8, 'hassan', 'hassan@gmail.com', 'teste2', '0549255042', '10 Boulevard Joseph Vallier', '2025-02-27', 'teste'),
(9, 'soltana farid', 'faridsoltana@gmail.com', 'membre fondateur ', '0552165108', 'cité 330 log bt26 n7 sebala draria alger', '2004-10-14', 'faridfarid');

-- --------------------------------------------------------

--
-- Structure de la table `panier`
--

CREATE TABLE `panier` (
  `id` int(11) NOT NULL,
  `produit_id` int(11) NOT NULL,
  `quantite` int(11) NOT NULL DEFAULT 1,
  `prix_unitaire` decimal(10,2) NOT NULL,
  `prix_total` decimal(10,2) GENERATED ALWAYS AS (`quantite` * `prix_unitaire`) STORED,
  `date_ajout` timestamp NOT NULL DEFAULT current_timestamp(),
  `image_produit` varchar(255) NOT NULL,
  `titre_produit` varchar(100) NOT NULL,
  `en_stock` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `panier`
--

INSERT INTO `panier` (`id`, `produit_id`, `quantite`, `prix_unitaire`, `date_ajout`, `image_produit`, `titre_produit`, `en_stock`) VALUES
(20, 66, 1, 3700.00, '2025-02-27 23:00:00', 'http://localhost:5050/images/photo_37.jpg', 'Produit 37', 1);

-- --------------------------------------------------------

--
-- Structure de la table `produits`
--

CREATE TABLE `produits` (
  `id` int(11) NOT NULL,
  `titre` varchar(255) NOT NULL,
  `categorie` varchar(100) NOT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `description` text NOT NULL,
  `prix` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `produits`
--

INSERT INTO `produits` (`id`, `titre`, `categorie`, `images`, `description`, `prix`) VALUES
(30, 'Produit 1', 'Cosmétiques', '[\"http://localhost:5050/images/1740405363179.jpg\",\"http://localhost:5050/images/1740405363179.jpg\"]', 'Description du produit 1', 100.00),
(31, 'Produit 2', 'Bijoux', '[\"http://localhost:5050/images/1740405380423.jpg\",\"http://localhost:5050/images/1740405380423.jpg\"]', 'Description du produit 2', 200.00),
(32, 'Produit 3', 'Accessoires', '[\"http://localhost:5050/images/1740404290506.jpg\",\"http://localhost:5050/images/1740404290506.jpg\"]', 'Description du produit 3', 300.00),
(33, 'Produit 4', 'Cosmétiques', '[\"http://localhost:5050/images/1740404306888.jpg\",\"http://localhost:5050/images/1740404306888.jpg\"]', 'Description du produit 4', 400.00),
(34, 'Produit 5', 'Bijoux', '[\"http://localhost:5050/images/1740404336201.jpg\",\"http://localhost:5050/images/1740404336201.jpg\"]', 'Description du produit 5', 500.00),
(35, 'Produit 6', 'Accessoires', '[\"http://localhost:5050/images/1740404356712.jpg\",\"http://localhost:5050/images/1740404356712.jpg\"]', 'Description du produit 6', 600.00),
(36, 'Produit 7', 'Cosmétiques', '[\"http://localhost:5050/images/photo_7.jpg\", \"http://localhost:5050/images/photo_7.jpg\"]', 'Description du produit 7', 700.00),
(37, 'Produit 8', 'Bijoux', '[\"http://localhost:5050/images/photo_8.jpg\", \"http://localhost:5050/images/photo_8.jpg\"]', 'Description du produit 8', 800.00),
(38, 'Produit 9', 'Accessoires', '[\"http://localhost:5050/images/photo_9.jpg\", \"http://localhost:5050/images/photo_9.jpg\"]', 'Description du produit 9', 900.00),
(39, 'Produit 10', 'Cosmétiques', '[\"http://localhost:5050/images/photo_10.jpg\", \"http://localhost:5050/images/photo_10.jpg\"]', 'Description du produit 10', 1000.00),
(40, 'Produit 11', 'Bijoux', '[\"http://localhost:5050/images/photo_11.jpg\", \"http://localhost:5050/images/photo_11.jpg\"]', 'Description du produit 11', 1100.00),
(41, 'Produit 12', 'Accessoires', '[\"http://localhost:5050/images/photo_12.jpg\", \"http://localhost:5050/images/photo_12.jpg\"]', 'Description du produit 12', 1200.00),
(42, 'Produit 13', 'Cosmétiques', '[\"http://localhost:5050/images/photo_13.jpg\", \"http://localhost:5050/images/photo_13.jpg\"]', 'Description du produit 13', 1300.00),
(43, 'Produit 14', 'Bijoux', '[\"http://localhost:5050/images/photo_14.jpg\", \"http://localhost:5050/images/photo_14.jpg\"]', 'Description du produit 14', 1400.00),
(44, 'Produit 15', 'Accessoires', '[\"http://localhost:5050/images/photo_15.jpg\", \"http://localhost:5050/images/photo_15.jpg\"]', 'Description du produit 15', 1500.00),
(45, 'Produit 16', 'Cosmétiques', '[\"http://localhost:5050/images/photo_16.jpg\", \"http://localhost:5050/images/photo_16.jpg\"]', 'Description du produit 16', 1600.00),
(46, 'Produit 17', 'Bijoux', '[\"http://localhost:5050/images/photo_17.jpg\", \"http://localhost:5050/images/photo_17.jpg\"]', 'Description du produit 17', 1700.00),
(47, 'Produit 18', 'Accessoires', '[\"http://localhost:5050/images/photo_18.jpg\", \"http://localhost:5050/images/photo_18.jpg\"]', 'Description du produit 18', 1800.00),
(48, 'Produit 19', 'Cosmétiques', '[\"http://localhost:5050/images/photo_19.jpg\", \"http://localhost:5050/images/photo_19.jpg\"]', 'Description du produit 19', 1900.00),
(49, 'Produit 20', 'Bijoux', '[\"http://localhost:5050/images/photo_20.jpg\", \"http://localhost:5050/images/photo_20.jpg\"]', 'Description du produit 20', 2000.00),
(50, 'Produit 21', 'Accessoires', '[\"http://localhost:5050/images/photo_21.jpg\", \"http://localhost:5050/images/photo_21.jpg\"]', 'Description du produit 21', 2100.00),
(51, 'Produit 22', 'Cosmétiques', '[\"http://localhost:5050/images/photo_22.jpg\", \"http://localhost:5050/images/photo_22.jpg\"]', 'Description du produit 22', 2200.00),
(52, 'Produit 23', 'Bijoux', '[\"http://localhost:5050/images/photo_23.jpg\", \"http://localhost:5050/images/photo_23.jpg\"]', 'Description du produit 23', 2300.00),
(53, 'Produit 24', 'Accessoires', '[\"http://localhost:5050/images/photo_24.jpg\", \"http://localhost:5050/images/photo_24.jpg\"]', 'Description du produit 24', 2400.00),
(54, 'Produit 25', 'Cosmétiques', '[\"http://localhost:5050/images/photo_25.jpg\", \"http://localhost:5050/images/photo_25.jpg\"]', 'Description du produit 25', 2500.00),
(55, 'Produit 26', 'Bijoux', '[\"http://localhost:5050/images/photo_26.jpg\", \"http://localhost:5050/images/photo_26.jpg\"]', 'Description du produit 26', 2600.00),
(56, 'Produit 27', 'Accessoires', '[\"http://localhost:5050/images/photo_27.jpg\", \"http://localhost:5050/images/photo_27.jpg\"]', 'Description du produit 27', 2700.00),
(57, 'Produit 28', 'Cosmétiques', '[\"http://localhost:5050/images/photo_28.jpg\", \"http://localhost:5050/images/photo_28.jpg\"]', 'Description du produit 28', 2800.00),
(58, 'Produit 29', 'Bijoux', '[\"http://localhost:5050/images/photo_29.jpg\", \"http://localhost:5050/images/photo_29.jpg\"]', 'Description du produit 29', 2900.00),
(59, 'Produit 30', 'Accessoires', '[\"http://localhost:5050/images/1740468757458.jpg\"]', 'Description du produit 30', 3000.00),
(60, 'Produit 31', 'Cosmétiques', '[\"http://localhost:5050/images/photo_31.jpg\", \"http://localhost:5050/images/photo_31.jpg\"]', 'Description du produit 31', 3100.00),
(61, 'Produit 32', 'Bijoux', '[\"http://localhost:5050/images/photo_32.jpg\", \"http://localhost:5050/images/photo_32.jpg\"]', 'Description du produit 32', 3200.00),
(62, 'Produit 33', 'Accessoires', '[\"http://localhost:5050/images/photo_33.jpg\", \"http://localhost:5050/images/photo_33.jpg\"]', 'Description du produit 33', 3300.00),
(63, 'Produit 34', 'Cosmétiques', '[\"http://localhost:5050/images/photo_34.jpg\", \"http://localhost:5050/images/photo_34.jpg\"]', 'Description du produit 34', 3400.00),
(64, 'Produit 35', 'Bijoux', '[\"http://localhost:5050/images/photo_35.jpg\", \"http://localhost:5050/images/photo_35.jpg\"]', 'Description du produit 35', 3500.00),
(65, 'Produit 36', 'Accessoires', '[\"http://localhost:5050/images/photo_36.jpg\", \"http://localhost:5050/images/photo_36.jpg\"]', 'Description du produit 36', 3600.00),
(66, 'Produit 37', 'Cosmétiques', '[\"http://localhost:5050/images/photo_37.jpg\", \"http://localhost:5050/images/photo_37.jpg\"]', 'Description du produit 37', 3700.00),
(67, 'Produit 38', 'Bijoux', '[\"http://localhost:5050/images/photo_38.jpg\", \"http://localhost:5050/images/photo_38.jpg\"]', 'Description du produit 38', 3800.00),
(68, 'Produit 39', 'Accessoires', '[\"http://localhost:5050/images/photo_39.jpg\", \"http://localhost:5050/images/photo_39.jpg\"]', 'Description du produit 39', 3900.00),
(69, 'Produit 40', 'Cosmétiques', '[\"http://localhost:5050/images/photo_40.jpg\", \"http://localhost:5050/images/photo_40.jpg\"]', 'Description du produit 40', 4000.00),
(70, 'Produit 41', 'Bijoux', '[\"http://localhost:5050/images/photo_41.jpg\", \"http://localhost:5050/images/photo_41.jpg\"]', 'Description du produit 41', 4100.00),
(71, 'Produit 42', 'Accessoires', '[\"http://localhost:5050/images/photo_42.jpg\", \"http://localhost:5050/images/photo_42.jpg\"]', 'Description du produit 42', 4200.00),
(72, 'Produit 43', 'Cosmétiques', '[\"http://localhost:5050/images/photo_43.jpg\", \"http://localhost:5050/images/photo_43.jpg\"]', 'Description du produit 43', 4300.00),
(74, 'Produit 45', 'Accessoires', '[\"http://localhost:5050/images/photo_45.jpg\", \"http://localhost:5050/images/photo_45.jpg\"]', 'Description du produit 45', 4500.00),
(75, 'Produit 46', 'Cosmétiques', '[\"http://localhost:5050/images/photo_46.jpg\", \"http://localhost:5050/images/photo_46.jpg\"]', 'Description du produit 46', 4600.00),
(76, 'Produit 47', 'Bijoux', '[\"http://localhost:5050/images/photo_47.jpg\", \"http://localhost:5050/images/photo_47.jpg\"]', 'Description du produit 47', 4700.00),
(77, 'Produit 48', 'Accessoires', '[\"http://localhost:5050/images/photo_48.jpg\", \"http://localhost:5050/images/photo_48.jpg\"]', 'Description du produit 48', 4800.00),
(104, 'Produit 44', 'Accessoires', '[\"http://localhost:5050/images/1740340141826.jpg\"]', 'Produit 44', 90.00);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `admin_membre`
--
ALTER TABLE `admin_membre`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Index pour la table `commandes`
--
ALTER TABLE `commandes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `info_admin`
--
ALTER TABLE `info_admin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Index pour la table `panier`
--
ALTER TABLE `panier`
  ADD PRIMARY KEY (`id`),
  ADD KEY `produit_id` (`produit_id`);

--
-- Index pour la table `produits`
--
ALTER TABLE `produits`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `admin_membre`
--
ALTER TABLE `admin_membre`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT pour la table `commandes`
--
ALTER TABLE `commandes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `info_admin`
--
ALTER TABLE `info_admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `panier`
--
ALTER TABLE `panier`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT pour la table `produits`
--
ALTER TABLE `produits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=105;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `panier`
--
ALTER TABLE `panier`
  ADD CONSTRAINT `panier_ibfk_1` FOREIGN KEY (`produit_id`) REFERENCES `produits` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
