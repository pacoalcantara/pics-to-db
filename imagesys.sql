-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.1.54-community


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema imagesys
--

CREATE DATABASE IF NOT EXISTS imagesys;
USE imagesys;


--
-- Definition of table `images`
--

DROP TABLE IF EXISTS `images`;
CREATE TABLE `images` (
  `num` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) CHARACTER SET utf8 NOT NULL,
  `uid` varchar(255) CHARACTER SET utf8 NOT NULL,
  `category` int(11) DEFAULT NULL,
  `outputdata` text CHARACTER SET utf8,
  `file_update` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_width` int(11) DEFAULT NULL,
  `exif_height` int(11) DEFAULT NULL,
  `exif_filesize` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_update` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_taken` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_md5` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_maker` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_model` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_rotation` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_exposure` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_fstop` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_iso` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_bias` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_wb` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_dist` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `exif_flash` varchar(55) CHARACTER SET utf8 DEFAULT NULL,
  `image_data` longblob,
  `image_gif` longblob,
  `remarks` text CHARACTER SET utf8,
  PRIMARY KEY (`num`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_bin MAX_ROWS=4294967295 AVG_ROW_LENGTH=50000 PACK_KEYS=0 ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `images`
--

/*!40000 ALTER TABLE `images` DISABLE KEYS */;
/*!40000 ALTER TABLE `images` ENABLE KEYS */;


/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
