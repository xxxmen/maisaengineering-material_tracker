-- MySQL dump 10.11
--
-- Host: localhost    Database: po_tracker
-- ------------------------------------------------------
-- Server version	5.0.51b

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `units` (
  `id` int(11) NOT NULL auto_increment,
  `description` varchar(80) default NULL,
  `lock_version` int(11) default '0',
  `updated_at` datetime default NULL,
  `created_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=152 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;

--
-- Dumping data for table `units`
--

LOCK TABLES `units` WRITE;
/*!40000 ALTER TABLE `units` DISABLE KEYS */;
INSERT INTO `units` VALUES (92,'NAPHTHA SPLITTER #1',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(91,'MULTIPLE UNITS',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(90,'MTBE',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(89,'JOY AIR COMPRESSOR #4',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(88,'JOY AIR COMPRESSOR #3',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(87,'ISO OCTENE',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(86,'TREATER #1',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(85,'REFORMER #2',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(84,'REFORMER #1',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(83,'EAST VAPOR CAUSTIC TOWER',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(82,'DEBUTANIZER #4',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(81,'DEBUTANIZER #3',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(80,'DEBUTANIZER #1',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(79,'DEA #5',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(78,'DEA #4',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(77,'DEA #3',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(76,'DEA #2',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(75,'DEA #1',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(74,'SOUTH DEA CONTACTER',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(73,'HDS (FFHDS)',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(72,'COOLING TOWER #11',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(71,'COOLING TOWER #09',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(70,'COOLING TOWER #08',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(69,'COOLING TOWER #06',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(68,'COOLING TOWER #05',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(67,'COOLING TOWER #04',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(66,'COOLING TOWER #03',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(65,'COOLING TOWER #02',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(64,'COOLING TOWER #01',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(63,'COKER GAS FRAC',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(62,'COKER #2',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(61,'CGF SWING',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(60,'BOILER #41',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(51,'SOUR WATER STRIPPER B',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(50,'SOUR WATER STRIPPER A',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(49,'NORTH AREA DIB',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(48,'LED',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(47,'COOLING TOWER #15',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(46,'VACUUM #52',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(45,'CRUDE #2',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(44,'SUPPORT SERVICES',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(43,'WASH SLAB',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(42,'DEBUTANIZER #2',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(41,'NESHAPS SOUTH',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(40,'FFHDS',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(39,'COOLING TOWER #14',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(38,'COOLING TOWER #13',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(37,'COOLING TOWER #12',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(36,'COOLING TOWER #10',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(35,'COOLING TOWER #07',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(34,'SRD',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(33,'VACUUM #51',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(32,'TAIL GAS #2',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(31,'TAIL GAS #1',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(30,'STEAM PLANT #4',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(29,'REFORMER/DESULF #2',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(28,'REFORMER/DESULF #1',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(27,'REFORMER #3',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(26,'MIDBARREL',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(25,'LRU',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(24,'LPG',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(23,'LIGHT HYDRO',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(22,'JET TREATER',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(21,'ISOM',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(20,'HYDROGEN PLANT #2',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(19,'HYDROGEN PLANT #1',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(18,'HYDROCRACKER',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(17,'FCC',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(16,'DEHEX #2',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(15,'DEHEX #1',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(14,'CRUDE #4',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(13,'CRUDE #1',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(12,'COKER #1',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(11,'CLAUS D',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(10,'CLAUS C',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(8,'CLAUS B',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(6,'CLAUS A',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(5,'C-3 SPLITTER',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(4,'BUTAMER',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(3,'ALKY',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(2,'ALKY MEROX',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(1,'UNSPECIFIED',0,'2007-08-10 00:22:12','2007-04-03 00:00:00'),(93,'NAPHTHA SPLITTER #2',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(94,'NAPHTHA SPLITTER #3',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(95,'NESHAPS NORTH',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(96,'NORTH AREA SOUR WATER DRUM',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(97,'NORTH NESHAPS',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(98,'SOUTH AREA DIB',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(99,'SULFUR PLANT',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(100,'5TH SECTION',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(101,'OFFICE SUPPLIES',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(102,'WAREHOUSE',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(103,'SURPLUS',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(104,'SLAB',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(105,'TOOL TRAILERS',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(106,'TAR PROCUREMENT',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(107,'SFIA',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(108,'ISOSIV',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(109,'SOUR WATER OXID # 2',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(110,'DESULFURIZER #2',0,'2007-08-10 00:22:13','2007-04-06 00:00:00'),(111,'DEPROPANIZER-FCC #2',0,'2007-08-10 00:22:13','2007-04-06 00:00:00'),(112,'ALKY DEPENT',0,'2007-08-10 00:22:13','2007-04-03 00:00:00'),(113,'WEST VAPOR CAUSTIC TOWER',0,'2007-08-10 00:22:13','2007-06-22 00:00:00'),(114,'ROUTINE',0,'2007-08-10 00:22:13','2007-07-10 00:00:00'),(131,'FCC FLARE',0,'2008-02-05 06:53:18','2008-02-05 06:53:18'),(116,'FLARE #5',0,'2007-11-16 06:35:55','2007-11-16 06:13:37'),(117,'STORAGE & HANDLING',0,'2007-11-28 14:29:03','2007-11-28 14:29:03'),(118,'COKER GAS MEROX #4600',0,'2007-12-07 11:05:53','2007-12-07 11:05:53'),(119,'SPENT ACID HANDLING',0,'2007-12-18 11:20:40','2007-12-18 11:20:40'),(121,'#5 TRAP',0,'2008-01-18 06:17:53','2008-01-18 06:17:53'),(141,'HDS FLARE',0,'2008-02-05 06:53:31','2008-02-05 06:53:31'),(151,'H/C FLARE',0,'2008-02-05 06:53:47','2008-02-05 06:53:47');
/*!40000 ALTER TABLE `units` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-01-08 18:41:18
