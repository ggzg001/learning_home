/*
SQLyog Ultimate v10.00 Beta1
MySQL - 5.7.18-log : Database - girls
*********************************************************************
*/


/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`girls` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `girls`;

/*Table structure for table `admin` */

DROP TABLE IF EXISTS `admin`;

CREATE TABLE `admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(10) NOT NULL,
  `password` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

/*Data for the table `admin` */

insert  into `admin`(`id`,`username`,`password`) values (1,'john','8888'),(2,'lyt','6666');

/*Table structure for table `beauty` */

DROP TABLE IF EXISTS `beauty`;

CREATE TABLE `beauty` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `sex` char(1) DEFAULT '女',
  `borndate` datetime DEFAULT '1987-01-01 00:00:00',
  `phone` varchar(11) NOT NULL,
  `photo` blob,
  `boyfriend_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

/*Data for the table `beauty` */

insert  into `beauty`(`id`,`name`,`sex`,`borndate`,`phone`,`photo`,`boyfriend_id`) values (1,'郭芙蓉','女','1988-02-03 00:00:00','18209876577',NULL,8),(2,'诺澜','女','1987-12-30 00:00:00','18219876577',NULL,9),(3,'美加','女','1989-02-03 00:00:00','18209876567',NULL,3),(4,'热巴','女','1993-02-03 00:00:00','18209876579',NULL,2),(5,'悠悠','女','1992-02-03 00:00:00','18209179577',NULL,9),(6,'秦羽墨','女','1988-02-03 00:00:00','18209876577',NULL,1),(7,'胡一菲','女','1987-12-30 00:00:00','18219876577',NULL,9),(8,'宛瑜','女','1989-02-03 00:00:00','18209876567',NULL,1),(9,'赛貂蝉','女','1993-02-03 00:00:00','18209876579',NULL,9),(10,'无双','女','1992-02-03 00:00:00','18209179577',NULL,4),(11,'小贝','女','1993-02-03 00:00:00','18209876579',NULL,9),(12,'佟湘玉','女','1992-02-03 00:00:00','18209179577',NULL,1);

/*Table structure for table `boys` */

DROP TABLE IF EXISTS `boys`;

CREATE TABLE `boys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `boyName` varchar(20) DEFAULT NULL,
  `userCP` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

/*Data for the table `boys` */

insert  into `boys`(`id`,`boyName`,`userCP`) values (1,'白展堂',100),(2,'吕秀才',800),(3,'李大嘴',50),(4,'燕小六',300);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
