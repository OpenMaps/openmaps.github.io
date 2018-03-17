-- phpMyAdmin SQL Dump
-- version 4.1.6
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Apr 07, 2015 at 06:57 AM
-- Server version: 5.6.16
-- PHP Version: 5.5.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `ajax`
--

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE IF NOT EXISTS `departments` (
  `department_id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `department` varchar(30) NOT NULL,
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `department` (`department`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`department_id`, `department`) VALUES
(2, 'Accounting'),
(1, 'Human Resources'),
(3, 'Marketing'),
(4, 'Redundancy Department');

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE IF NOT EXISTS `employees` (
  `employee_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `department_id` tinyint(3) unsigned NOT NULL,
  `first_name` varchar(20) NOT NULL,
  `last_name` varchar(40) NOT NULL,
  `email` varchar(60) NOT NULL,
  `phone_ext` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`employee_id`),
  UNIQUE KEY `email` (`email`),
  KEY `department_id` (`department_id`),
  KEY `last_name` (`last_name`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=26 ;

--
-- Dumping data for table `employees`
--

INSERT INTO `employees` (`employee_id`, `department_id`, `first_name`, `last_name`, `email`, `phone_ext`) VALUES
(1, 1, 'Laila', 'Smith', 'l.smith@thiscompany.com', 234),
(2, 1, 'Laverne', 'Green', 'l.green@thiscompany.com', 235),
(3, 1, 'Cal', 'Perez', 'c.perez@thiscompany.com', 230),
(4, 1, 'Brian', 'Rogers', 'brianr@thiscompany.com', 231),
(5, 1, 'Carla', 'Cox', 'cc@thiscompany.com', 233),
(6, 2, 'Ezra', 'Howard', 'e.howard@thiscompany.com', 122),
(7, 2, 'Gideon', 'Gray', 'g.gray@thiscompany.com', 128),
(8, 2, 'Penelope', 'Brooks', 'pb@thiscompany.com', 129),
(9, 2, 'Olive', 'Kelly', 'olive@thiscompany.com', 120),
(10, 2, 'Justine', 'Sanders', 'j.sanders@thiscompany.com', 123),
(11, 2, 'Zoe', 'Ford', 'zoe@thiscompany.com', 125),
(12, 3, 'Sam', 'Fisher', 'sam@thiscompany.com', 385),
(13, 3, 'Henry', 'Barnes', 'henry@thiscompany.com', 386),
(14, 3, 'Eleanor', 'Wood', 'eleanor@thiscompany.com', 387),
(15, 4, 'Emmet', 'Humphries', 'e.humphries@thiscompany.com', 401),
(16, 4, 'Conrad', 'Madsen', 'conrad@thiscompany.com', 410),
(17, 4, 'Maude', 'Ernst', 'm.ernst@thiscompany.com', 409),
(18, 4, 'Stella', 'Redding', 's.redding@thiscompany.com', 408),
(19, 4, 'Nat', 'Fugatn', 'nat@thiscompany.com', 407),
(20, 4, 'Hazel', 'Hay', 'h.hay@thiscompany.com', 402),
(21, 1, 'joel', 'Irungu', 'irush@gmail.com', 123),
(22, 1, 'joshua', 'mwaura', 'joshuairungu12@gmail.com', 345),
(23, 4, 'Edwin', 'burugu', 'burugulogistics@gmail.com', 456),
(24, 2, 'Joshua', 'mwaura', 'muniubiashara14@gmail.com', 123),
(25, 4, 'Mwaura Joshua', 'burugu', 'mo0720mo@gmail.com', 858);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(40) NOT NULL,
  `pass` char(40) NOT NULL,
  `first_name` varchar(15) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `active` char(32) DEFAULT NULL,
  `registration_date` datetime NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `email_2` (`email`,`pass`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `email`, `pass`, `first_name`, `last_name`, `active`, `registration_date`) VALUES
(1, 'joshuairungu12@gmail.com', 'e064fdd9590c28d2bedf15f13d71fe5ee36c2204', 'joshua', 'mwaura', '1f8c676d0662cb7645453735f7b579e4', '2015-04-05 20:43:23'),
(2, 'jamesepuret12@gmail.com', 'e064fdd9590c28d2bedf15f13d71fe5ee36c2204', 'james', 'epuret', 'dcd76c63c13614cbbccc98202543d92b', '2015-04-05 20:59:48'),
(3, 'joshua.irungu@students.jkuat.ac.ke', 'e064fdd9590c28d2bedf15f13d71fe5ee36c2204', 'joshua', 'mwaura', '622ecc860d429b1e8a0de9e1caf5f56d', '2015-04-05 21:24:58'),
(4, 'allanwise@gmail.com', 'dd731834ad8d2507c2747b8c3c8030d64c6283f2', 'Edwin', 'burugu', '5db9bcf021c4cd5c47cc6797e2085f63', '2015-04-05 22:13:49');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
