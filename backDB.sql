CREATE DATABASE  IF NOT EXISTS `managedb` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;
USE `managedb`;
-- MySQL dump 10.13  Distrib 8.0.14, for Win64 (x86_64)
--
-- Host: localhost    Database: managedb
-- ------------------------------------------------------
-- Server version	8.0.14

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts_account`
--

DROP TABLE IF EXISTS `accounts_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `accounts_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `country` varchar(255) DEFAULT NULL,
  `image` varchar(100) DEFAULT NULL,
  `activation_key` varchar(120) DEFAULT NULL,
  `activated` tinyint(1) NOT NULL,
  `added` datetime(6) NOT NULL,
  `updated` datetime(6) NOT NULL,
  `gender_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `address1` varchar(255) DEFAULT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `comments` longtext,
  `phone_number1` int(11) DEFAULT NULL,
  `phone_number2` int(11) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `block_review` tinyint(1) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `accounts_account_gender_id_dae04d94_fk_accounts_gender_id` (`gender_id`),
  CONSTRAINT `accounts_account_gender_id_dae04d94_fk_accounts_gender_id` FOREIGN KEY (`gender_id`) REFERENCES `accounts_gender` (`id`),
  CONSTRAINT `accounts_account_user_id_d61b40c6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_account`
--

LOCK TABLES `accounts_account` WRITE;
/*!40000 ALTER TABLE `accounts_account` DISABLE KEYS */;
INSERT INTO `accounts_account` VALUES (1,'23','default.png',NULL,1,'2019-02-07 01:16:17.009731','2019-02-07 01:16:17.009731',3,3,'dont tell you .','545','comments',5454,545454,'4454',0,'sxjin@milize.co.jp3','jin','SHUXIN','sxjin'),(2,'23','default.png',NULL,1,'2019-02-07 01:16:17.009731','2019-02-07 01:16:17.009731',3,1,'dont tell you .','545','comments',5454,545454,'4454',0,'sxjin@milize.co.jp1','jin','SHUXIN','sxjin'),(3,'23','profile_small.jpg',NULL,1,'2019-02-12 01:37:58.600577','2019-02-12 01:41:41.662871',4,2,'dont tell you .','545','not',5454,545454,'4454',0,'sxjin@milize.co.jp','jin','SHUXIN','sx');
/*!40000 ALTER TABLE `accounts_account` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_gender`
--

DROP TABLE IF EXISTS `accounts_gender`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `accounts_gender` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sex` varchar(12) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_gender`
--

LOCK TABLES `accounts_gender` WRITE;
/*!40000 ALTER TABLE `accounts_gender` DISABLE KEYS */;
INSERT INTO `accounts_gender` VALUES (3,'Male'),(4,'Female');
/*!40000 ALTER TABLE `accounts_gender` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
INSERT INTO `auth_group` VALUES (3,'admin'),(2,'sx'),(1,'sxjin');
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_group_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
INSERT INTO `auth_group_permissions` VALUES (1,1,1),(2,1,2),(3,1,3),(4,1,4),(5,1,5),(6,1,6),(7,1,7),(8,1,8),(9,1,9),(10,1,10),(11,1,11),(12,1,12),(13,1,13),(14,1,14),(15,1,15),(16,1,16),(17,1,17),(18,1,18),(19,1,19),(20,1,20),(21,1,21),(22,1,22),(23,1,23),(24,1,24),(25,1,25),(26,1,26),(27,1,27),(28,1,28),(29,1,29),(30,1,30),(31,1,31),(32,1,32),(33,1,33),(34,1,34),(35,1,35),(36,1,36),(37,1,37),(38,1,38),(39,1,39),(40,1,40),(41,1,41),(42,1,42),(43,1,43),(44,1,44),(45,1,45),(46,1,46),(47,1,47),(48,1,48),(49,1,49),(50,1,50),(51,1,51),(52,1,52);
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session'),(25,'Can add account',7,'add_account'),(26,'Can change account',7,'change_account'),(27,'Can delete account',7,'delete_account'),(28,'Can view account',7,'view_account'),(29,'Can add gender',8,'add_gender'),(30,'Can change gender',8,'change_gender'),(31,'Can delete gender',8,'delete_gender'),(32,'Can view gender',8,'view_gender'),(33,'Can add category',9,'add_category'),(34,'Can change category',9,'change_category'),(35,'Can delete category',9,'delete_category'),(36,'Can view category',9,'view_category'),(37,'Can add product',10,'add_product'),(38,'Can change product',10,'change_product'),(39,'Can delete product',10,'delete_product'),(40,'Can view product',10,'view_product'),(41,'Can add checkout',11,'add_checkout'),(42,'Can change checkout',11,'change_checkout'),(43,'Can delete checkout',11,'delete_checkout'),(44,'Can view checkout',11,'view_checkout'),(45,'Can add review',12,'add_review'),(46,'Can change review',12,'change_review'),(47,'Can delete review',12,'delete_review'),(48,'Can view review',12,'view_review'),(49,'Can add contact us',13,'add_contactus'),(50,'Can change contact us',13,'change_contactus'),(51,'Can delete contact us',13,'delete_contactus'),(52,'Can view contact us',13,'view_contactus'),(53,'Can add PayPal IPN',14,'add_paypalipn'),(54,'Can change PayPal IPN',14,'change_paypalipn'),(55,'Can delete PayPal IPN',14,'delete_paypalipn'),(56,'Can view PayPal IPN',14,'view_paypalipn'),(57,'Can add order',15,'add_order'),(58,'Can change order',15,'change_order'),(59,'Can delete order',15,'delete_order'),(60,'Can view order',15,'view_order'),(61,'Can add order item',16,'add_orderitem'),(62,'Can change order item',16,'change_orderitem'),(63,'Can delete order item',16,'delete_orderitem'),(64,'Can view order item',16,'view_orderitem');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$120000$ubZNr4ncgtlZ$aonbmXLD1xdGcNB8u7935zuJNbwxtUVP6Q+jKqlfaRE=','2019-02-15 06:29:24.470388',1,'sxjin','hhh','SHUXIN','sxjin@milize.co.jp1',1,1,'2019-02-06 03:51:01.003508'),(2,'pbkdf2_sha256$120000$ubZNr4ncgtlZ$aonbmXLD1xdGcNB8u7935zuJNbwxtUVP6Q+jKqlfaRE=','2019-02-20 07:41:36.164067',0,'sx','jin','SHUXIN','sxjin@milize.co.jp',1,1,'2019-02-12 01:37:58.212999'),(3,'pbkdf2_sha256$120000$ubZNr4ncgtlZ$aonbmXLD1xdGcNB8u7935zuJNbwxtUVP6Q+jKqlfaRE=','2019-02-13 01:24:20.424405',1,'admin','admin','admin','sxjin@milize.co.jp',1,1,'2019-02-12 01:37:58.212999');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_user_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
INSERT INTO `auth_user_groups` VALUES (1,1,1),(2,2,2),(3,3,1);
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_user_user_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_us_contactus`
--

DROP TABLE IF EXISTS `contact_us_contactus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `contact_us_contactus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `e_mail` varchar(254) NOT NULL,
  `phone` int(10) unsigned NOT NULL,
  `message` longtext NOT NULL,
  `seen` tinyint(1) NOT NULL,
  `added` datetime(6) NOT NULL,
  `updated` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_us_contactus`
--

LOCK TABLES `contact_us_contactus` WRITE;
/*!40000 ALTER TABLE `contact_us_contactus` DISABLE KEYS */;
INSERT INTO `contact_us_contactus` VALUES (1,'sxjin','sxjin@milize.co.jp',322333,'wewewewe',0,'2019-02-07 00:59:35.561121','2019-02-07 00:59:35.561121');
/*!40000 ALTER TABLE `contact_us_contactus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'2019-02-07 01:15:00.810756','2','female',3,'',8,1),(2,'2019-02-07 01:15:00.969567','1','male',3,'',8,1),(3,'2019-02-07 01:15:15.187971','3','Male',1,'[{\"added\": {}}]',8,1),(4,'2019-02-07 01:15:25.094600','4','Female',1,'[{\"added\": {}}]',8,1),(5,'2019-02-07 01:16:17.099099','2','sxjin',1,'[{\"added\": {}}]',7,1),(6,'2019-02-07 01:17:18.211524','1','sxjin',1,'[{\"added\": {}}]',3,1),(7,'2019-02-13 01:32:31.771327','2','1',2,'[{\"changed\": {\"fields\": [\"status\"]}}]',11,3),(8,'2019-02-13 01:36:37.432336','2','1',2,'[]',11,3),(9,'2019-02-13 01:36:52.073295','2','1',3,'',11,3);
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (7,'accounts','account'),(8,'accounts','gender'),(1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(4,'auth','user'),(13,'contact_us','contactus'),(5,'contenttypes','contenttype'),(14,'ipn','paypalipn'),(11,'orders','checkout'),(15,'orders','order'),(16,'orders','orderitem'),(9,'products','category'),(10,'products','product'),(12,'reviews','review'),(6,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `django_migrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2019-02-06 03:44:08.982641'),(2,'auth','0001_initial','2019-02-06 03:44:30.853498'),(3,'accounts','0001_initial','2019-02-06 03:44:41.928353'),(4,'accounts','0002_auto_20180124_2143','2019-02-06 03:44:47.040562'),(5,'accounts','0003_auto_20180125_1815','2019-02-06 03:44:50.434149'),(6,'accounts','0004_account_block_review','2019-02-06 03:44:50.950538'),(7,'accounts','0005_auto_20180202_1235','2019-02-06 03:44:57.269674'),(8,'admin','0001_initial','2019-02-06 03:45:01.101955'),(9,'admin','0002_logentry_remove_auto_add','2019-02-06 03:45:01.178978'),(10,'admin','0003_logentry_add_action_flag_choices','2019-02-06 03:45:01.306393'),(11,'contenttypes','0002_remove_content_type_name','2019-02-06 03:45:04.818035'),(12,'auth','0002_alter_permission_name_max_length','2019-02-06 03:45:07.071251'),(13,'auth','0003_alter_user_email_max_length','2019-02-06 03:45:07.748066'),(14,'auth','0004_alter_user_username_opts','2019-02-06 03:45:07.794967'),(15,'auth','0005_alter_user_last_login_null','2019-02-06 03:45:09.114925'),(16,'auth','0006_require_contenttypes_0002','2019-02-06 03:45:09.198249'),(17,'auth','0007_alter_validators_add_error_messages','2019-02-06 03:45:09.452054'),(18,'auth','0008_alter_user_username_max_length','2019-02-06 03:45:11.704130'),(19,'auth','0009_alter_user_last_name_max_length','2019-02-06 03:45:16.117754'),(20,'contact_us','0001_initial','2019-02-06 03:45:17.890153'),(21,'contact_us','0002_auto_20180202_1235','2019-02-06 03:45:18.008856'),(22,'orders','0001_initial','2019-02-06 03:45:20.675094'),(23,'orders','0002_checkout_product_id','2019-02-06 03:45:21.684242'),(24,'orders','0003_checkout_slug','2019-02-06 03:45:23.187117'),(25,'orders','0004_auto_20180129_2252','2019-02-06 03:45:23.365326'),(26,'orders','0005_auto_20180129_2257','2019-02-06 03:45:23.688673'),(27,'orders','0006_auto_20180129_2352','2019-02-06 03:45:23.788972'),(28,'orders','0007_auto_20180131_2114','2019-02-06 03:45:25.067798'),(29,'orders','0008_auto_20180202_1235','2019-02-06 03:45:25.170771'),(30,'products','0001_initial','2019-02-06 03:45:30.707477'),(31,'products','0002_auto_20180126_1108','2019-02-06 03:45:32.127737'),(32,'products','0003_auto_20180126_1110','2019-02-06 03:45:40.685245'),(33,'products','0004_product_discount','2019-02-06 03:45:41.202462'),(34,'products','0005_product_slug','2019-02-06 03:45:43.227853'),(35,'products','0006_auto_20180126_1229','2019-02-06 03:45:46.170013'),(36,'products','0007_auto_20180126_1231','2019-02-06 03:45:49.271457'),(37,'products','0008_auto_20180128_1451','2019-02-06 03:45:52.717180'),(38,'products','0009_auto_20180128_1453','2019-02-06 03:46:03.925965'),(39,'products','0010_auto_20180128_1555','2019-02-06 03:46:04.211076'),(40,'products','0011_auto_20180128_1617','2019-02-06 03:46:06.129566'),(41,'products','0012_auto_20180128_1658','2019-02-06 03:46:06.414776'),(42,'products','0013_auto_20180128_1827','2019-02-06 03:46:06.746839'),(43,'products','0014_product_slider','2019-02-06 03:46:09.222295'),(44,'products','0015_product_block_review','2019-02-06 03:46:11.327710'),(45,'products','0016_auto_20180202_1231','2019-02-06 03:46:11.674500'),(46,'reviews','0001_initial','2019-02-06 03:46:22.272391'),(47,'reviews','0002_auto_20180131_2049','2019-02-06 03:46:22.604276'),(48,'reviews','0003_auto_20180131_2051','2019-02-06 03:46:22.741968'),(49,'sessions','0001_initial','2019-02-06 03:46:24.631679'),(50,'ipn','0001_initial','2019-02-15 07:33:34.874223'),(51,'ipn','0002_paypalipn_mp_id','2019-02-15 07:33:35.964799'),(52,'ipn','0003_auto_20141117_1647','2019-02-15 07:33:43.620347'),(53,'ipn','0004_auto_20150612_1826','2019-02-15 07:34:55.930709'),(54,'ipn','0005_auto_20151217_0948','2019-02-15 07:34:59.092617'),(55,'ipn','0006_auto_20160108_1112','2019-02-15 07:35:04.979106'),(56,'ipn','0007_auto_20160219_1135','2019-02-15 07:35:05.122711'),(57,'ipn','0008_auto_20190212_1231','2019-02-15 07:35:05.286273'),(58,'accounts','0006_auto_20190219_1146','2019-02-19 02:47:12.206550'),(59,'products','0017_auto_20190219_1146','2019-02-19 02:47:12.300263');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('5orpwtrgoarcj5edglgrvcrzdjvc9uwv','ZDAwYjcxOTQ4MjRkMTBhZjNhNTg4MmUyNDg0OTQ4NjlmYzJhYzJhYjp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhY2FkYWNmNmZmYzcwNDFhMTA0YmY0NDUwNTA2MTRkY2YzMDMxOTVmIn0=','2019-02-27 01:57:01.586401'),('b6kv1fqrtj4ozud3rie5dhvzg6xmpwk3','ZjIzZjMzYjdjN2VmZjZkMmJhNzZjOTIwZGMyZDMxZjdmNzE4MzMyNTp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhY2FkYWNmNmZmYzcwNDFhMTA0YmY0NDUwNTA2MTRkY2YzMDMxOTVmIiwib3JkZXJfaWQiOjUwfQ==','2019-03-07 00:11:18.944943'),('c53fzuv5abivbkius2jo0q13foa2lxsv','MDkyYjY4MzUwOWVkOWM5MjRmYzYxYzJmZjkwYzExODgxZTc3ODExYTp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhY2FkYWNmNmZmYzcwNDFhMTA0YmY0NDUwNTA2MTRkY2YzMDMxOTVmIiwib3JkZXJfaWQiOjE4fQ==','2019-03-04 01:56:30.347925'),('d69k8l757ab33a9pgqkbv0hlhveaw478','M2E4MzIxNmZlNmM0MjczOTUyM2VlNjBlMTMwODg3ZjkxMTQ3YmFjMzp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhY2FkYWNmNmZmYzcwNDFhMTA0YmY0NDUwNTA2MTRkY2YzMDMxOTVmIiwib3JkZXJfaWQiOjI1fQ==','2019-03-04 06:14:08.380137'),('dhtvnk2ucqe1wg4ycuompkx7bgkehhie','ODNhMzVjZTY1YjNjYzFmZjE5MDk3MzQ1ODZlN2Y1NjY0MDIzMzg0Yzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJlZDg0ZDI3YzczOTlkZTU0NmRjY2Q0ZGNkNGI5NDE2NTMzNzQzNTY5In0=','2019-02-20 03:55:23.227699'),('fgjrxmoigzwfbbk8xbdam1e8ei8s2yow','YjI4YWI1MzE2MGU0N2NiNTc5ZGI0YjRlMzFlMzNmMzY4MGJlMmE3MDp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJlYWVhMzRlNmY4NTA4ZDVkODc1NDIxYjZjYjc2MDkxMTViOTVhYWQ3In0=','2019-02-26 01:41:14.254431'),('fylf200zhss9ixlkw41kdoca8yki37b6','ZDAwYjcxOTQ4MjRkMTBhZjNhNTg4MmUyNDg0OTQ4NjlmYzJhYzJhYjp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhY2FkYWNmNmZmYzcwNDFhMTA0YmY0NDUwNTA2MTRkY2YzMDMxOTVmIn0=','2019-02-28 02:14:35.456843'),('o7oqzcqfjoibs6g0zbt6ii3dg5e9aowc','ZDAwYjcxOTQ4MjRkMTBhZjNhNTg4MmUyNDg0OTQ4NjlmYzJhYzJhYjp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhY2FkYWNmNmZmYzcwNDFhMTA0YmY0NDUwNTA2MTRkY2YzMDMxOTVmIn0=','2019-02-28 23:44:02.771265'),('om6ecs1aofljwwkbowifb1cmzrp98ew9','MmZiZDFiNzJiMTVkM2E0YjRlYmQzYWQxOWExMWFhY2Q2YzNlOWQzZDp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhY2FkYWNmNmZmYzcwNDFhMTA0YmY0NDUwNTA2MTRkY2YzMDMxOTVmIiwib3JkZXJfaWQiOjQyfQ==','2019-03-06 07:03:23.613812'),('qssjuygz2jaqi833ph6on51woc11ujp2','NzlmNjQ3Y2QxMTliMTFhYmFkYzQ2YTMzNzdjOTdiYWZhY2RjNjhlNTp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhY2FkYWNmNmZmYzcwNDFhMTA0YmY0NDUwNTA2MTRkY2YzMDMxOTVmIiwib3JkZXJfaWQiOjE1fQ==','2019-03-01 08:03:05.954558');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders_checkout`
--

DROP TABLE IF EXISTS `orders_checkout`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `orders_checkout` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` int(10) unsigned NOT NULL,
  `quantity` int(10) unsigned NOT NULL,
  `discount` double DEFAULT NULL,
  `image` varchar(100) NOT NULL,
  `added` datetime(6) NOT NULL,
  `updated` datetime(6) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(10) unsigned NOT NULL,
  `slug` varchar(50) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `totolp` decimal(10,0) DEFAULT NULL,
  `paid` tinyint(3) unsigned zerofill NOT NULL,
  PRIMARY KEY (`id`),
  KEY `orders_checkout_user_id_f7f1c807_fk_auth_user_id` (`user_id`),
  KEY `orders_checkout_slug_a252e952` (`slug`),
  CONSTRAINT `orders_checkout_user_id_f7f1c807_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders_checkout`
--

LOCK TABLES `orders_checkout` WRITE;
/*!40000 ALTER TABLE `orders_checkout` DISABLE KEYS */;
INSERT INTO `orders_checkout` VALUES (15,'pending','Times User',2,2,0,'jj.jpg','2019-02-15 07:57:23.887124','2019-02-15 08:02:15.270720',1,2,'2',15,NULL,000),(25,'pending','Times User',2,1,0,'jj.jpg','2019-02-18 06:10:32.973682','2019-02-18 06:12:14.755341',2,2,'2',25,NULL,000),(26,'pending','Times User',2,1,0,'jj.jpg','2019-02-18 06:28:34.740304','2019-02-19 01:22:49.143576',2,2,'2',26,NULL,000),(27,'pending','One Month User',30,1,0.2,'jj.jpg','2019-02-19 01:23:23.106938','2019-02-19 01:23:34.065780',2,1,'1',27,NULL,000),(28,'pending','One Month User',30,1,0.2,'jj.jpg','2019-02-19 02:34:37.099160','2019-02-19 02:35:25.445165',2,1,'1',28,NULL,000),(29,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 02:54:45.062922','2019-02-19 02:54:48.042430',2,2,'2',29,NULL,000),(30,'pending','One Month User',30,1,0.2,'jj.jpg','2019-02-19 02:56:45.694954','2019-02-19 02:56:48.717555',2,1,'1',30,NULL,000),(31,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 02:57:18.472979','2019-02-19 02:57:21.137577',2,2,'2',31,NULL,000),(32,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 03:01:12.813333','2019-02-19 03:01:21.274388',2,2,'2',32,NULL,000),(33,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 03:14:20.057521','2019-02-19 03:14:27.642898',2,2,'2',33,NULL,000),(34,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 03:17:06.677001','2019-02-19 03:17:14.728258',2,2,'2',34,NULL,000),(35,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 03:21:19.353854','2019-02-19 03:21:28.189132',2,2,'2',35,NULL,000),(36,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 03:23:57.458754','2019-02-19 03:24:05.058212',2,2,'2',36,NULL,000),(37,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 03:32:56.894583','2019-02-19 03:33:03.752965',2,2,'2',37,NULL,000),(38,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 03:36:30.651085','2019-02-19 03:36:38.410059',2,2,'2',38,NULL,000),(39,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 03:40:43.443806','2019-02-19 03:40:50.530442',2,2,'2',39,NULL,000),(40,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 03:42:48.077504','2019-02-19 03:42:53.448837',2,2,'2',40,NULL,000),(41,'pending','Times User',2,1,0,'jj.jpg','2019-02-19 03:46:18.285895','2019-02-19 03:47:32.683579',2,2,'2',41,NULL,000),(42,'pending','3 Month User',90,1,1,'jj.jpg','2019-02-20 07:02:45.779023','2019-02-20 07:03:22.390830',2,4,'4',42,NULL,000),(43,'pending','Times User',2,1,0,'jj.jpg','2019-02-20 23:46:36.396804','2019-02-20 23:46:39.839944',2,2,'2',43,NULL,000),(44,'pending','Times User',2,1,0,'jj.jpg','2019-02-20 23:49:52.209476','2019-02-20 23:49:59.064365',2,2,'2',44,NULL,000),(45,'pending','Times User',2,1,0,'jj.jpg','2019-02-20 23:57:20.701024','2019-02-20 23:57:27.438467',2,2,'2',45,NULL,000),(46,'pending','Times User',2,1,0,'jj.jpg','2019-02-20 23:58:30.263317','2019-02-20 23:58:40.828194',2,2,'2',46,NULL,000),(47,'pending','Times User',2,1,0,'jj.jpg','2019-02-21 00:02:26.342213','2019-02-21 00:02:33.213756',2,2,'2',47,NULL,000),(48,'pending','Times User',2,1,0,'jj.jpg','2019-02-21 00:03:26.498072','2019-02-21 00:03:32.448351',2,2,'2',48,NULL,000),(49,'pending','Times User',2,1,0,'jj.jpg','2019-02-21 00:10:00.239454','2019-02-21 00:10:11.326371',2,2,'2',49,NULL,000),(50,'pending','Times User',2,1,0,'jj.jpg','2019-02-21 00:11:06.902135','2019-02-21 00:11:18.065553',2,2,'2',50,NULL,000);
/*!40000 ALTER TABLE `orders_checkout` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders_order`
--

DROP TABLE IF EXISTS `orders_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `orders_order` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(254) NOT NULL,
  `address` varchar(250) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `city` varchar(100) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `paid` tinyint(1) unsigned zerofill NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders_order`
--

LOCK TABLES `orders_order` WRITE;
/*!40000 ALTER TABLE `orders_order` DISABLE KEYS */;
INSERT INTO `orders_order` VALUES (6,'hhh','ghgh','sss@fddd.com','ghhhg','ghhhggh','Tokyo','2019-02-05 05:56:15','2019-02-05 05:56:15',0),(18,'jin','SHUXIN','sxjin@milize.co.jp','ghhhg','ghhhggh','東京都','2019-02-19 00:44:17','2019-02-19 00:44:17',0),(19,'hhh','SHUXIN','sxjin@milize.co.jp','ghhhg','ghhhggh','東京都','2019-02-19 01:03:58','2019-02-19 01:03:58',0);
/*!40000 ALTER TABLE `orders_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders_orderitem`
--

DROP TABLE IF EXISTS `orders_orderitem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `orders_orderitem` (
  `id` int(11) DEFAULT NULL,
  `price` double DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders_orderitem`
--

LOCK TABLES `orders_orderitem` WRITE;
/*!40000 ALTER TABLE `orders_orderitem` DISABLE KEYS */;
INSERT INTO `orders_orderitem` VALUES (6,20,5,5,7),(7,20000,1,5,1),(8,20,1,6,7),(9,20,2,7,7),(10,30,1,8,8),(11,800,1,9,4),(12,20,2,11,7),(13,30,2,12,8),(14,2000,1,13,1),(15,200,1,14,2),(16,600,2,15,7),(17,600,1,16,7),(18,2000,1,17,1),(19,1200,1,18,6),(20,600,1,19,5);
/*!40000 ALTER TABLE `orders_orderitem` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paypal_ipn`
--

DROP TABLE IF EXISTS `paypal_ipn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `paypal_ipn` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `business` varchar(127) NOT NULL,
  `charset` varchar(255) NOT NULL,
  `custom` varchar(256) NOT NULL,
  `notify_version` decimal(64,2) DEFAULT NULL,
  `parent_txn_id` varchar(19) NOT NULL,
  `receiver_email` varchar(254) NOT NULL,
  `receiver_id` varchar(255) NOT NULL,
  `residence_country` varchar(2) NOT NULL,
  `test_ipn` tinyint(1) NOT NULL,
  `txn_id` varchar(255) NOT NULL,
  `txn_type` varchar(255) NOT NULL,
  `verify_sign` varchar(255) NOT NULL,
  `address_country` varchar(64) NOT NULL,
  `address_city` varchar(40) NOT NULL,
  `address_country_code` varchar(64) NOT NULL,
  `address_name` varchar(128) NOT NULL,
  `address_state` varchar(40) NOT NULL,
  `address_status` varchar(255) NOT NULL,
  `address_street` varchar(200) NOT NULL,
  `address_zip` varchar(20) NOT NULL,
  `contact_phone` varchar(20) NOT NULL,
  `first_name` varchar(64) NOT NULL,
  `last_name` varchar(64) NOT NULL,
  `payer_business_name` varchar(127) NOT NULL,
  `payer_email` varchar(127) NOT NULL,
  `payer_id` varchar(13) NOT NULL,
  `auth_amount` decimal(64,2) DEFAULT NULL,
  `auth_exp` varchar(28) NOT NULL,
  `auth_id` varchar(19) NOT NULL,
  `auth_status` varchar(255) NOT NULL,
  `exchange_rate` decimal(64,16) DEFAULT NULL,
  `invoice` varchar(127) NOT NULL,
  `item_name` varchar(127) NOT NULL,
  `item_number` varchar(127) NOT NULL,
  `mc_currency` varchar(32) NOT NULL,
  `mc_fee` decimal(64,2) DEFAULT NULL,
  `mc_gross` decimal(64,2) DEFAULT NULL,
  `mc_handling` decimal(64,2) DEFAULT NULL,
  `mc_shipping` decimal(64,2) DEFAULT NULL,
  `memo` varchar(255) NOT NULL,
  `num_cart_items` int(11) DEFAULT NULL,
  `option_name1` varchar(64) NOT NULL,
  `option_name2` varchar(64) NOT NULL,
  `payer_status` varchar(255) NOT NULL,
  `payment_date` datetime(6) DEFAULT NULL,
  `payment_gross` decimal(64,2) DEFAULT NULL,
  `payment_status` varchar(255) NOT NULL,
  `payment_type` varchar(255) NOT NULL,
  `pending_reason` varchar(255) NOT NULL,
  `protection_eligibility` varchar(255) NOT NULL,
  `quantity` int(11) DEFAULT NULL,
  `reason_code` varchar(255) NOT NULL,
  `remaining_settle` decimal(64,2) DEFAULT NULL,
  `settle_amount` decimal(64,2) DEFAULT NULL,
  `settle_currency` varchar(32) NOT NULL,
  `shipping` decimal(64,2) DEFAULT NULL,
  `shipping_method` varchar(255) NOT NULL,
  `tax` decimal(64,2) DEFAULT NULL,
  `transaction_entity` varchar(255) NOT NULL,
  `auction_buyer_id` varchar(64) NOT NULL,
  `auction_closing_date` datetime(6) DEFAULT NULL,
  `auction_multi_item` int(11) DEFAULT NULL,
  `for_auction` decimal(64,2) DEFAULT NULL,
  `amount` decimal(64,2) DEFAULT NULL,
  `amount_per_cycle` decimal(64,2) DEFAULT NULL,
  `initial_payment_amount` decimal(64,2) DEFAULT NULL,
  `next_payment_date` datetime(6) DEFAULT NULL,
  `outstanding_balance` decimal(64,2) DEFAULT NULL,
  `payment_cycle` varchar(255) NOT NULL,
  `period_type` varchar(255) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `product_type` varchar(255) NOT NULL,
  `profile_status` varchar(255) NOT NULL,
  `recurring_payment_id` varchar(255) NOT NULL,
  `rp_invoice_id` varchar(127) NOT NULL,
  `time_created` datetime(6) DEFAULT NULL,
  `amount1` decimal(64,2) DEFAULT NULL,
  `amount2` decimal(64,2) DEFAULT NULL,
  `amount3` decimal(64,2) DEFAULT NULL,
  `mc_amount1` decimal(64,2) DEFAULT NULL,
  `mc_amount2` decimal(64,2) DEFAULT NULL,
  `mc_amount3` decimal(64,2) DEFAULT NULL,
  `password` varchar(24) NOT NULL,
  `period1` varchar(255) NOT NULL,
  `period2` varchar(255) NOT NULL,
  `period3` varchar(255) NOT NULL,
  `reattempt` varchar(1) NOT NULL,
  `recur_times` int(11) DEFAULT NULL,
  `recurring` varchar(1) NOT NULL,
  `retry_at` datetime(6) DEFAULT NULL,
  `subscr_date` datetime(6) DEFAULT NULL,
  `subscr_effective` datetime(6) DEFAULT NULL,
  `subscr_id` varchar(19) NOT NULL,
  `username` varchar(64) NOT NULL,
  `case_creation_date` datetime(6) DEFAULT NULL,
  `case_id` varchar(255) NOT NULL,
  `case_type` varchar(255) NOT NULL,
  `receipt_id` varchar(255) NOT NULL,
  `currency_code` varchar(32) NOT NULL,
  `handling_amount` decimal(64,2) DEFAULT NULL,
  `transaction_subject` varchar(256) NOT NULL,
  `ipaddress` char(39) DEFAULT NULL,
  `flag` tinyint(1) NOT NULL,
  `flag_code` varchar(16) NOT NULL,
  `flag_info` longtext NOT NULL,
  `query` longtext NOT NULL,
  `response` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `from_view` varchar(6) DEFAULT NULL,
  `mp_id` varchar(128) DEFAULT NULL,
  `option_selection1` varchar(200) NOT NULL,
  `option_selection2` varchar(200) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `paypal_ipn_txn_id_8fa22c44` (`txn_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paypal_ipn`
--

LOCK TABLES `paypal_ipn` WRITE;
/*!40000 ALTER TABLE `paypal_ipn` DISABLE KEYS */;
INSERT INTO `paypal_ipn` VALUES (5,'shuxin.jin-facilitator@hotmail.com','windows-1252','',4.00,'','shuxin.jin-facilitator@hotmail.com','TMRXF6E4EKTM6','US',1,'2KJ75079K5630732N','A2Ab3TV1KoEWBTo5Y55GiXA2cdWNAQb0xuobMXa4vybGp-jwByUJrHXG','','','','','','','','','','test','buyer','','dikeooel3ski-buyer@gmail.com','CQXX6MYAKR3GJ','0',0.00,'','','0',5.0000000000000000,'Order 5','','TWD','0',20100.00,0.00,0.00,0.00,'0',1,'','verified','2017-08-21 13:09:02',NULL,0.00,'instant','multi_currency','Ineligible','1',1,'0',0.00,1.00,'0',0.00,'0',0.00,'','0','2009-01-01 00:00:00.000000',0,0.00,0.00,0.00,0.00,'2010-11-01 00:00:00.000000',0.00,'','','','','','0','0','2010-01-01 00:00:00.000000',0.00,0.00,0.00,0.00,0.00,0.00,'','','','','0',0,'0','2010-01-01 00:00:00.000000',NULL,'2010-01-01 00:00:00.000000','','0','2010-01-01 00:00:00.000000','','','USD','0',0.00,'127.0.0.1','0',0,'','transaction_subject=&txn_type=web_accept&payment_date=06%3A09%3A02+Aug+21%2C+2017+PDT&last_name=buyer&residence_country=US&pending_reason=multi_currency&item_name=Order+5&payment_gross=&mc_currency=TWD&business=dikeooel3ski-facilitator%40gmail.com&payment_type=instant&protection_eligibility=Ineligible&verify_sign=A2Ab3TV1KoEWBTo5Y55GiXA2cdWNAQb0xuobMXa4vybGp-jwByUJrHXG&payer_status=verified&test_ipn=1&payer_email=dikeooel3ski-buyer%40gmail.com&txn_id=2KJ75079K5630732N&quantity=1&receiver_email=dikeooel3ski-facilitator%40gmail.com&first_name=test&invoice=5&payer_id=CQXX6MYAKR3GJ&receiver_id=TMRXF6E4EKTM6&item_number=&payment_status=Pending&mc_gross=20100&custom=&charset=windows-1252&notify_version=3.8&ipn_track_id=b71750fddab01','VERIFIED','2017-08-21 13:09:23','2017-08-21 13:09:23.000000','2010-01-01 00:00:00.000000','0','0','0','web_accept'),(6,'shuxin.jin-facilitator@hotmail.com','windows-1252','',4.00,'','shuxin.jin-facilitator@hotmail.com','TMRXF6E4EKTM6','US',1,'2KJ75079K5630732N','AGV6csTg6wZeXiLA3TJ1jLQ3z0LlA0jFS5H1RmWDETW270yF7g88sh3X','','','','','','','','','','test','buyer','','dikeooel3ski-buyer@gmail.com','CQXX6MYAKR3GJ','0',0.00,'','','0',5.0000000000000000,'Order 5','','TWD','593',20100.00,0.00,0.00,0.00,'0',1,'','verified','2017-08-21 13:09:02',NULL,0.00,'instant','','Ineligible','1',1,'0',641.00,1.00,'0',0.00,'0',0.00,'','0','2010-01-01 00:00:00.000000',0,0.00,0.00,0.00,0.00,'2010-11-11 00:00:00.000000',0.00,'','','','','','0','0','2010-01-01 00:00:00.000000',0.00,0.00,0.00,0.00,0.00,0.00,'','','','','0',0,'0','2010-01-01 00:00:00.000000',NULL,'2010-01-01 00:00:00.000000','','0','2010-01-01 00:00:00.000000','','','USD','0',0.00,'127.0.0.1','0',0,'','mc_gross=20100&invoice=5&settle_amount=640.92&protection_eligibility=Ineligible&payer_id=CQXX6MYAKR3GJ&tax=0&payment_date=06%3A09%3A02+Aug+21%2C+2017+PDT&payment_status=Completed&charset=windows-1252&first_name=test&mc_fee=593&exchange_rate=0.0328560&notify_version=3.8&custom=&settle_currency=USD&payer_status=verified&quantity=1&verify_sign=AGV6csTg6wZeXiLA3TJ1jLQ3z0LlA0jFS5H1RmWDETW270yF7g88sh3X&payer_email=dikeooel3ski-buyer%40gmail.com&txn_id=2KJ75079K5630732N&payment_type=instant&last_name=buyer&receiver_email=dikeooel3ski-facilitator%40gmail.com&payment_fee=&shipping_discount=0&insurance_amount=0&receiver_id=TMRXF6E4EKTM6&txn_type=web_accept&item_name=Order+5&discount=0&mc_currency=TWD&item_number=&residence_country=US&test_ipn=1&shipping_method=Default&handling_amount=0&transaction_subject=&payment_gross=&shipping=0&ipn_track_id=31f2c6d92cbf','VERIFIED','2017-08-21 13:11:45','2017-08-21 13:11:45.000000','2010-01-01 00:00:00.000000','0','0','0','web_accept');
/*!40000 ALTER TABLE `paypal_ipn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_category`
--

DROP TABLE IF EXISTS `products_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `products_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(255) NOT NULL,
  `number_of_products` int(11) DEFAULT NULL,
  `added` datetime(6) NOT NULL,
  `updated` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_category_category_200f1259_uniq` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_category`
--

LOCK TABLES `products_category` WRITE;
/*!40000 ALTER TABLE `products_category` DISABLE KEYS */;
INSERT INTO `products_category` VALUES (1,'1',1000000000,'2019-09-09 00:00:00.000000','2019-09-10 00:00:00.000000'),(2,'2',1000000000,'2019-09-09 00:00:00.000000','2019-09-10 00:00:00.000000'),(3,'3',1000000000,'2019-09-09 00:00:00.000000','2019-09-10 00:00:00.000000');
/*!40000 ALTER TABLE `products_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_product`
--

DROP TABLE IF EXISTS `products_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `products_product` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` int(10) unsigned NOT NULL,
  `quantity` int(10) unsigned NOT NULL,
  `number_of_sales` int(10) unsigned DEFAULT NULL,
  `number_of_views` int(10) unsigned DEFAULT NULL,
  `avg_rate` double DEFAULT NULL,
  `description` longtext NOT NULL,
  `image` varchar(100) NOT NULL,
  `publish` tinyint(1) NOT NULL,
  `added` datetime(6) NOT NULL,
  `updated` datetime(6) NOT NULL,
  `category_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `discount` double DEFAULT NULL,
  `slug` varchar(50) DEFAULT NULL,
  `slider` tinyint(1) NOT NULL,
  `block_review` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `products_product_category_id_9b594869_fk_products_category_id` (`category_id`),
  KEY `products_product_user_id_e04f062e_fk_auth_user_id` (`user_id`),
  CONSTRAINT `products_product_category_id_9b594869_fk_products_category_id` FOREIGN KEY (`category_id`) REFERENCES `products_category` (`id`),
  CONSTRAINT `products_product_user_id_e04f062e_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_product`
--

LOCK TABLES `products_product` WRITE;
/*!40000 ALTER TABLE `products_product` DISABLE KEYS */;
INSERT INTO `products_product` VALUES (1,'One Month User',30,7999993,2007,16350,5,'Month User,One month payment.','jj.jpg',1,'2019-01-01 00:00:00.000000','2019-02-19 02:56:48.793898',1,1,0.2,'1',0,0),(2,'Times User',2,7999963,1038,35000,5,'One time usage ,2 dollars for one time, 4 dollars for 2 times,so on.','jj.jpg',1,'2019-01-01 00:00:00.000000','2019-02-21 00:11:18.132373',2,1,0,'2',0,0),(3,'New User',0,8000000,10020,78050,5,'For new user, first time ,have a try of predict ,test,free!','jj.jpg',1,'2019-01-01 00:00:00.000000','2019-02-07 00:58:17.334207',3,1,100,'3',0,0),(4,'3 Month User',90,7999999,2001,16351,5,'3 Month User,Three month payment.','jj.jpg',1,'2019-01-01 00:00:00.000000','2019-02-20 07:33:15.572412',1,1,1,'4',0,0);
/*!40000 ALTER TABLE `products_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews_review`
--

DROP TABLE IF EXISTS `reviews_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `reviews_review` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rate` int(10) unsigned NOT NULL,
  `review` longtext NOT NULL,
  `added` datetime(6) NOT NULL,
  `updated` datetime(6) NOT NULL,
  `product_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `reviews_review_product_id_ce2fa4c6_fk_products_product_id` (`product_id`),
  KEY `reviews_review_user_id_875caff2_fk_auth_user_id` (`user_id`),
  CONSTRAINT `reviews_review_product_id_ce2fa4c6_fk_products_product_id` FOREIGN KEY (`product_id`) REFERENCES `products_product` (`id`),
  CONSTRAINT `reviews_review_user_id_875caff2_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews_review`
--

LOCK TABLES `reviews_review` WRITE;
/*!40000 ALTER TABLE `reviews_review` DISABLE KEYS */;
INSERT INTO `reviews_review` VALUES (1,5,'I like it ','2019-02-07 00:56:34.524637','2019-02-07 00:56:34.524637',1,1);
/*!40000 ALTER TABLE `reviews_review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usermanagement`
--

DROP TABLE IF EXISTS `usermanagement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `usermanagement` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(40) NOT NULL,
  `last_name` varchar(40) NOT NULL,
  `email` varchar(50) NOT NULL,
  `mobileno` varchar(20) NOT NULL,
  `temp_password` varchar(50) NOT NULL,
  `perm_password` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usermanagement`
--

LOCK TABLES `usermanagement` WRITE;
/*!40000 ALTER TABLE `usermanagement` DISABLE KEYS */;
INSERT INTO `usermanagement` VALUES (1,'ddd','ddd','edew@dsd.com','223323','222222',NULL);
/*!40000 ALTER TABLE `usermanagement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'managedb'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-02-21  9:27:34
CREATE DATABASE  IF NOT EXISTS `paytest` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `paytest`;
-- MySQL dump 10.13  Distrib 8.0.14, for Win64 (x86_64)
--
-- Host: localhost    Database: paytest
-- ------------------------------------------------------
-- Server version	8.0.14

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL,
  `name` varchar(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_group_permissions` (
  `id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,1,'add_logentry','Can add log entry'),(2,1,'change_logentry','Can change log entry'),(3,1,'delete_logentry','Can delete log entry'),(4,2,'add_permission','Can add permission'),(5,2,'change_permission','Can change permission'),(6,2,'delete_permission','Can delete permission'),(7,3,'add_group','Can add group'),(8,3,'change_group','Can change group'),(9,3,'delete_group','Can delete group'),(10,4,'add_user','Can add user'),(11,4,'change_user','Can change user'),(12,4,'delete_user','Can delete user'),(13,5,'add_contenttype','Can add content type'),(14,5,'change_contenttype','Can change content type'),(15,5,'delete_contenttype','Can delete content type'),(16,6,'add_session','Can add session'),(17,6,'change_session','Can change session'),(18,6,'delete_session','Can delete session'),(19,7,'add_category','Can add category'),(20,7,'change_category','Can change category'),(21,7,'delete_category','Can delete category'),(22,8,'add_product','Can add product'),(23,8,'change_product','Can change product'),(24,8,'delete_product','Can delete product'),(25,9,'add_order','Can add order'),(26,9,'change_order','Can change order'),(27,9,'delete_order','Can delete order'),(28,10,'add_orderitem','Can add order item'),(29,10,'change_orderitem','Can change order item'),(30,10,'delete_orderitem','Can delete order item'),(31,11,'add_paypalipn','Can add PayPal IPN'),(32,11,'change_paypalipn','Can change PayPal IPN'),(33,11,'delete_paypalipn','Can delete PayPal IPN');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime NOT NULL,
  `username` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$120000$ubZNr4ncgtlZ$aonbmXLD1xdGcNB8u7935zuJNbwxtUVP6Q+jKqlfaRE=','2019-02-14 03:25:48',1,'admin','admin','shuxin.jin@hotmail.com',1,1,'2017-08-20 14:03:14','admin'),(2,'pbkdf2_sha256$120000$ubZNr4ncgtlZ$aonbmXLD1xdGcNB8u7935zuJNbwxtUVP6Q+jKqlfaRE=','2017-08-21 12:19:47',1,'sxjin','sxjin','shuxin.joe@gmail.com',1,1,'2017-08-20 14:03:14','sxjin');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_user_groups` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auth_user_user_permissions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL,
  `object_id` text NOT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL,
  `change_message` text NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `action_time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'1','3C',1,'[{\"added\": {}}]',7,1,'2017-08-20 14:06:06'),(2,'2','book',1,'[{\"added\": {}}]',7,1,'2017-08-20 14:06:19'),(3,'3','food',1,'[{\"added\": {}}]',7,1,'2017-08-20 14:07:07'),(4,'4','daily necessity',1,'[{\"added\": {}}]',7,1,'2017-08-20 14:08:25'),(5,'1','iphone',1,'[{\"added\": {}}]',8,1,'2017-08-20 14:10:20'),(6,'2','note8',1,'[{\"added\": {}}]',8,1,'2017-08-20 14:10:59'),(7,'3','python tutorial',1,'[{\"added\": {}}]',8,1,'2017-08-20 14:12:10'),(8,'4','django awesome',1,'[{\"added\": {}}]',8,1,'2017-08-20 14:12:53'),(9,'5','hair dryer',1,'[{\"added\": {}}]',8,1,'2017-08-20 14:14:17'),(10,'6','Electric fan',1,'[{\"added\": {}}]',8,1,'2017-08-20 14:15:17'),(11,'7','apple',1,'[{\"added\": {}}]',8,1,'2017-08-20 14:15:39'),(12,'8','banana',1,'[{\"added\": {}}]',8,1,'2017-08-20 14:16:20'),(13,'6','electric fan',2,'[{\"changed\": {\"fields\": [\"name\"]}}]',8,1,'2017-08-20 14:16:45'),(14,'4','Order 4',3,'',9,1,'2017-08-21 13:04:56'),(15,'3','Order 3',3,'',9,1,'2017-08-21 13:04:56'),(16,'2','Order 2',3,'',9,1,'2017-08-21 13:04:56'),(17,'1','Order 1',3,'',9,1,'2017-08-21 13:04:56'),(18,'4','PayPalIPN: 4',3,'',11,1,'2017-08-21 13:05:18'),(19,'3','PayPalIPN: 3',3,'',11,1,'2017-08-21 13:05:18'),(20,'2','PayPalIPN: 2',3,'',11,1,'2017-08-21 13:05:18'),(21,'1','PayPalIPN: 1',3,'',11,1,'2017-08-21 13:05:18');
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(2,'auth','permission'),(3,'auth','group'),(4,'auth','user'),(5,'contenttypes','contenttype'),(6,'sessions','session'),(7,'shop','category'),(8,'shop','product'),(9,'orders','order'),(10,'orders','orderitem'),(11,'ipn','paypalipn');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `django_migrations` (
  `id` int(11) NOT NULL,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2017-08-20 13:59:46'),(2,'auth','0001_initial','2017-08-20 13:59:47'),(3,'admin','0001_initial','2017-08-20 13:59:47'),(4,'admin','0002_logentry_remove_auto_add','2017-08-20 13:59:47'),(5,'contenttypes','0002_remove_content_type_name','2017-08-20 13:59:47'),(6,'auth','0002_alter_permission_name_max_length','2017-08-20 13:59:47'),(7,'auth','0003_alter_user_email_max_length','2017-08-20 13:59:47'),(8,'auth','0004_alter_user_username_opts','2017-08-20 13:59:47'),(9,'auth','0005_alter_user_last_login_null','2017-08-20 13:59:47'),(10,'auth','0006_require_contenttypes_0002','2017-08-20 13:59:47'),(11,'auth','0007_alter_validators_add_error_messages','2017-08-20 13:59:47'),(12,'auth','0008_alter_user_username_max_length','2017-08-20 13:59:47'),(13,'ipn','0001_initial','2017-08-20 13:59:47'),(14,'ipn','0002_paypalipn_mp_id','2017-08-20 13:59:47'),(15,'ipn','0003_auto_20141117_1647','2017-08-20 13:59:47'),(16,'ipn','0004_auto_20150612_1826','2017-08-20 13:59:48'),(17,'ipn','0005_auto_20151217_0948','2017-08-20 13:59:48'),(18,'ipn','0006_auto_20160108_1112','2017-08-20 13:59:48'),(19,'ipn','0007_auto_20160219_1135','2017-08-20 13:59:48'),(20,'sessions','0001_initial','2017-08-20 13:59:48'),(21,'shop','0001_initial','2017-08-20 14:01:32'),(22,'orders','0001_initial','2017-08-20 14:01:49');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` text NOT NULL,
  `expire_date` datetime NOT NULL,
  PRIMARY KEY (`session_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('1f2hwa266mqn10jfcuz68qaks10kxitf','MWZjMjcxMTkwNzMyOGUyMGJkNDUyYTU3MDIzYzU5NTNiZTQzYmRlMTp7Im9yZGVyX2lkIjoxNiwiY2FydCI6e319','2019-03-01 01:30:03'),('1g9d7w824jsd30pcno5b6mqsur2aqwqj','ZGM3MzkwNmRhNjlhNmYwNzM4YzE1OTNiNGVmZjdiZmRkMjIzZWNlNjp7Im9yZGVyX2lkIjoxNCwiY2FydCI6e30sIl9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIyZmQyOWE5NmYyNzI3NjgzOTMyMDMyMzBmMWRmZmNjODFkOGZkNmZlIn0=','2019-02-28 03:29:07'),('1zgpg5z47o3o1wpsesg6jag79cpkwawz','YWZkZjQwZDMzNDNkNTJmYTZlMjg5OGY0ZWQzNjg3YmY5YjBlNTVhMTp7Im9yZGVyX2lkIjoxNywiY2FydCI6e319','2019-03-04 02:13:04'),('52ecm5fd0qa8n18j0biax3xbdyt6xxsg','ZGFjYzhiOTdhYWEzY2U4MDdjZWNiYWY3YmVjYmMwMjU5ZGE5NGI0MDp7Im9yZGVyX2lkIjoxMywiY2FydCI6e319','2019-02-28 02:00:32'),('fdsch0l2rg25vj9aaxu36sjgjudlurus','OTNiNDMyOWJhNTVlZDk5MDQ4MzYwZDkzMjA3ZGFkZGI1YWZkMTdhODp7Im9yZGVyX2lkIjoxMSwiY2FydCI6eyI4Ijp7InF1YW50aXR5IjoxLCJwcmljZSI6IjMwIn19fQ==','2019-02-27 00:51:17'),('fm1c0ss7obc48pf7eqcs0fd387u6zgkz','MWY2MTI4ODkwNmYwMTkzYjdjNWEyMWNjNTg4NWIwYzJmMTQ3OTQyZTp7ImNhcnQiOnt9LCJfYXV0aF91c2VyX2lkIjoiMSIsIl9hdXRoX3VzZXJfYmFja2VuZCI6ImRqYW5nby5jb250cmliLmF1dGguYmFja2VuZHMuTW9kZWxCYWNrZW5kIiwiX2F1dGhfdXNlcl9oYXNoIjoiNDhmMjk4NmUwNDFlNGRjYjc4ZjY4NGUwZTIyMDQ4NDFjMTM3NDA2OCJ9','2017-09-04 12:17:39'),('g9eszwzeim4c135dtopq4w9244ralqhw','ZGMwNzQxMmNhYTI2ODdjODFhNzEzMzQ2MDI2MzhmNzA3NGNiOGFiYzp7ImNhcnQiOnt9fQ==','2019-03-01 05:56:42'),('h0jjvnsoi9j9p2vzkh54u1w3tp54tyuv','ZGMwNzQxMmNhYTI2ODdjODFhNzEzMzQ2MDI2MzhmNzA3NGNiOGFiYzp7ImNhcnQiOnt9fQ==','2019-03-06 07:30:30'),('ljv2v7dmodhgaywcy1eert6zkubowanh','MjBkMjY3MTdmODQxMGRlNWQ0YTJkNjEwNWEzNDgxYTUzNzY2OGViMDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI0OGYyOTg2ZTA0MWU0ZGNiNzhmNjg0ZTBlMjIwNDg0MWMxMzc0MDY4Iiwib3JkZXJfaWQiOjUsImNhcnQiOnt9fQ==','2017-09-04 13:13:00'),('q2ojg5bezbcz1zgaabrcun4ukj40p9l4','MjQ2ODVjYjZhYWNhNzk3OTllNTY5YzNkMGM3ZGU5Y2VhODQxZjgxMjp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI0OGYyOTg2ZTA0MWU0ZGNiNzhmNjg0ZTBlMjIwNDg0MWMxMzc0MDY4Iiwib3JkZXJfaWQiOjEsImNhcnQiOnsiNyI6eyJxdWFudGl0eSI6MSwicHJpY2UiOiIyMCJ9LCI2Ijp7InF1YW50aXR5IjoxLCJwcmljZSI6IjEyMDAifX19','2017-09-04 11:51:28'),('qyzwexqjz3d2bwgx1bwbo6n8w3fao7q0','ZjI1YTkxZDA4NWFiMDY0ZWI3OTU0ZTllM2RhNGEzMjE1YTBmOTMwNjp7Im9yZGVyX2lkIjoxOSwiY2FydCI6e319','2019-03-05 01:04:02'),('tv9u48o3isfbahbj7a6ab2u9vn57o5yd','ZGMwNzQxMmNhYTI2ODdjODFhNzEzMzQ2MDI2MzhmNzA3NGNiOGFiYzp7ImNhcnQiOnt9fQ==','2019-03-01 05:31:11'),('wn3j03ull4h7mzirujgrez3omwaga4ko','MGFiZGQ1OTFiMzEyYjJmZDc4ZTczY2FjZmJjN2FhYThlOGU5OWIwNzp7Im9yZGVyX2lkIjo3LCJjYXJ0Ijp7fX0=','2019-02-19 05:57:08'),('wuo471vmtmw8gr29sf4wdk5hxvkeu49d','MjZjNjk4Yjk4YTQ4MGUyZTc5MTdhMTliNzQ1MjVjYjc5MjI1YjZmOTp7Im9yZGVyX2lkIjo5LCJjYXJ0Ijp7fX0=','2019-02-22 07:22:21');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders_order`
--

DROP TABLE IF EXISTS `orders_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `orders_order` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(254) NOT NULL,
  `address` varchar(250) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `city` varchar(100) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `paid` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders_order`
--

LOCK TABLES `orders_order` WRITE;
/*!40000 ALTER TABLE `orders_order` DISABLE KEYS */;
INSERT INTO `orders_order` VALUES (6,'hhh','ghgh','sss@fddd.com','ghhhg','ghhhggh','Tokyo','2019-02-05 05:56:15','2019-02-05 05:56:15',0),(18,'jin','SHUXIN','sxjin@milize.co.jp','ghhhg','ghhhggh','東京都','2019-02-19 00:44:17','2019-02-19 00:44:17',0),(19,'hhh','SHUXIN','sxjin@milize.co.jp','ghhhg','ghhhggh','東京都','2019-02-19 01:03:58','2019-02-19 01:03:58',0);
/*!40000 ALTER TABLE `orders_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders_orderitem`
--

DROP TABLE IF EXISTS `orders_orderitem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `orders_orderitem` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `price` decimal(10,0) NOT NULL,
  `quantity` int(10) unsigned NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders_orderitem`
--

LOCK TABLES `orders_orderitem` WRITE;
/*!40000 ALTER TABLE `orders_orderitem` DISABLE KEYS */;
INSERT INTO `orders_orderitem` VALUES (6,20,5,5,7),(7,20000,1,5,1),(8,20,1,6,7),(9,20,2,7,7),(10,30,1,8,8),(11,800,1,9,4),(12,20,2,11,7),(13,30,2,12,8),(14,2000,1,13,1),(15,200,1,14,2),(16,600,2,15,7),(17,600,1,16,7),(18,2000,1,17,1),(19,1200,1,18,6),(20,600,1,19,5);
/*!40000 ALTER TABLE `orders_orderitem` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paypal_ipn`
--

DROP TABLE IF EXISTS `paypal_ipn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `paypal_ipn` (
  `id` int(11) NOT NULL,
  `business` varchar(127) NOT NULL,
  `charset` varchar(255) NOT NULL,
  `custom` varchar(256) NOT NULL,
  `notify_version` decimal(10,0) DEFAULT NULL,
  `parent_txn_id` varchar(19) NOT NULL,
  `receiver_email` varchar(254) NOT NULL,
  `receiver_id` varchar(255) NOT NULL,
  `residence_country` varchar(2) NOT NULL,
  `test_ipn` tinyint(1) NOT NULL,
  `txn_id` varchar(255) NOT NULL,
  `verify_sign` varchar(255) NOT NULL,
  `address_country` varchar(64) NOT NULL,
  `address_city` varchar(40) NOT NULL,
  `address_country_code` varchar(64) NOT NULL,
  `address_name` varchar(128) NOT NULL,
  `address_state` varchar(40) NOT NULL,
  `address_status` varchar(255) NOT NULL,
  `address_street` varchar(200) NOT NULL,
  `address_zip` varchar(20) NOT NULL,
  `contact_phone` varchar(20) NOT NULL,
  `first_name` varchar(64) NOT NULL,
  `last_name` varchar(64) NOT NULL,
  `payer_business_name` varchar(127) NOT NULL,
  `payer_email` varchar(127) NOT NULL,
  `payer_id` varchar(13) NOT NULL,
  `auth_amount` decimal(10,0) DEFAULT NULL,
  `auth_exp` varchar(28) NOT NULL,
  `auth_id` varchar(19) NOT NULL,
  `auth_status` varchar(255) NOT NULL,
  `exchange_rate` decimal(10,0) DEFAULT NULL,
  `invoice` varchar(127) NOT NULL,
  `item_name` varchar(127) NOT NULL,
  `item_number` varchar(127) NOT NULL,
  `mc_currency` varchar(32) NOT NULL,
  `mc_fee` decimal(10,0) DEFAULT NULL,
  `mc_gross` decimal(10,0) DEFAULT NULL,
  `mc_handling` decimal(10,0) DEFAULT NULL,
  `mc_shipping` decimal(10,0) DEFAULT NULL,
  `memo` varchar(255) NOT NULL,
  `num_cart_items` int(11) DEFAULT NULL,
  `option_name1` varchar(64) NOT NULL,
  `option_name2` varchar(64) NOT NULL,
  `payer_status` varchar(255) NOT NULL,
  `payment_date` datetime DEFAULT NULL,
  `payment_gross` decimal(10,0) DEFAULT NULL,
  `payment_status` varchar(255) NOT NULL,
  `payment_type` varchar(255) NOT NULL,
  `pending_reason` varchar(255) NOT NULL,
  `protection_eligibility` varchar(255) NOT NULL,
  `quantity` int(11) DEFAULT NULL,
  `reason_code` varchar(255) NOT NULL,
  `remaining_settle` decimal(10,0) DEFAULT NULL,
  `settle_amount` decimal(10,0) DEFAULT NULL,
  `settle_currency` varchar(32) NOT NULL,
  `shipping` decimal(10,0) DEFAULT NULL,
  `shipping_method` varchar(255) NOT NULL,
  `tax` decimal(10,0) DEFAULT NULL,
  `transaction_entity` varchar(255) NOT NULL,
  `auction_buyer_id` varchar(64) NOT NULL,
  `auction_closing_date` datetime DEFAULT NULL,
  `auction_multi_item` int(11) DEFAULT NULL,
  `for_auction` decimal(10,0) DEFAULT NULL,
  `amount` decimal(10,0) DEFAULT NULL,
  `amount_per_cycle` decimal(10,0) DEFAULT NULL,
  `initial_payment_amount` decimal(10,0) DEFAULT NULL,
  `next_payment_date` datetime DEFAULT NULL,
  `outstanding_balance` decimal(10,0) DEFAULT NULL,
  `payment_cycle` varchar(255) NOT NULL,
  `period_type` varchar(255) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `product_type` varchar(255) NOT NULL,
  `profile_status` varchar(255) NOT NULL,
  `recurring_payment_id` varchar(255) NOT NULL,
  `rp_invoice_id` varchar(127) NOT NULL,
  `time_created` datetime DEFAULT NULL,
  `amount1` decimal(10,0) DEFAULT NULL,
  `amount2` decimal(10,0) DEFAULT NULL,
  `amount3` decimal(10,0) DEFAULT NULL,
  `mc_amount1` decimal(10,0) DEFAULT NULL,
  `mc_amount2` decimal(10,0) DEFAULT NULL,
  `mc_amount3` decimal(10,0) DEFAULT NULL,
  `password` varchar(24) NOT NULL,
  `period1` varchar(255) NOT NULL,
  `period2` varchar(255) NOT NULL,
  `period3` varchar(255) NOT NULL,
  `reattempt` varchar(1) NOT NULL,
  `recur_times` int(11) DEFAULT NULL,
  `recurring` varchar(1) NOT NULL,
  `retry_at` datetime DEFAULT NULL,
  `subscr_date` datetime DEFAULT NULL,
  `subscr_effective` datetime DEFAULT NULL,
  `subscr_id` varchar(19) NOT NULL,
  `username` varchar(64) NOT NULL,
  `case_creation_date` datetime DEFAULT NULL,
  `case_id` varchar(255) NOT NULL,
  `case_type` varchar(255) NOT NULL,
  `receipt_id` varchar(255) NOT NULL,
  `currency_code` varchar(32) NOT NULL,
  `handling_amount` decimal(10,0) DEFAULT NULL,
  `transaction_subject` varchar(256) NOT NULL,
  `ipaddress` char(39) DEFAULT NULL,
  `flag` tinyint(1) NOT NULL,
  `flag_code` varchar(16) NOT NULL,
  `flag_info` text NOT NULL,
  `query` text NOT NULL,
  `response` text NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `from_view` varchar(6) DEFAULT NULL,
  `mp_id` varchar(128) DEFAULT NULL,
  `option_selection1` varchar(200) NOT NULL,
  `option_selection2` varchar(200) NOT NULL,
  `txn_type` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paypal_ipn`
--

LOCK TABLES `paypal_ipn` WRITE;
/*!40000 ALTER TABLE `paypal_ipn` DISABLE KEYS */;
INSERT INTO `paypal_ipn` VALUES (5,'dikeooel3ski-facilitator@gmail.com','windows-1252','',4,'','dikeooel3ski-facilitator@gmail.com','TMRXF6E4EKTM6','US',1,'2KJ75079K5630732N','A2Ab3TV1KoEWBTo5Y55GiXA2cdWNAQb0xuobMXa4vybGp-jwByUJrHXG','','','','','','','','','','test','buyer','','dikeooel3ski-buyer@gmail.com','CQXX6MYAKR3GJ',0,'','','',0,'5','Order 5','','TWD',0,20100,0,0,'',0,'','','verified','2017-08-21 13:09:02',NULL,'Pending','instant','multi_currency','Ineligible',1,'',0,0,'',0,'',0,'','',NULL,0,0,0,0,0,NULL,0,'','','','','','','',NULL,0,0,0,0,0,0,'','','','','',0,'',NULL,NULL,NULL,'','',NULL,'','','','USD',0,'','127.0.0.1',0,'','','transaction_subject=&txn_type=web_accept&payment_date=06%3A09%3A02+Aug+21%2C+2017+PDT&last_name=buyer&residence_country=US&pending_reason=multi_currency&item_name=Order+5&payment_gross=&mc_currency=TWD&business=dikeooel3ski-facilitator%40gmail.com&payment_type=instant&protection_eligibility=Ineligible&verify_sign=A2Ab3TV1KoEWBTo5Y55GiXA2cdWNAQb0xuobMXa4vybGp-jwByUJrHXG&payer_status=verified&test_ipn=1&payer_email=dikeooel3ski-buyer%40gmail.com&txn_id=2KJ75079K5630732N&quantity=1&receiver_email=dikeooel3ski-facilitator%40gmail.com&first_name=test&invoice=5&payer_id=CQXX6MYAKR3GJ&receiver_id=TMRXF6E4EKTM6&item_number=&payment_status=Pending&mc_gross=20100&custom=&charset=windows-1252&notify_version=3.8&ipn_track_id=b71750fddab01','VERIFIED','2017-08-21 13:09:23','2017-08-21 13:09:23',NULL,NULL,'','','web_accept'),(6,'','windows-1252','',4,'','dikeooel3ski-facilitator@gmail.com','TMRXF6E4EKTM6','US',1,'2KJ75079K5630732N','AGV6csTg6wZeXiLA3TJ1jLQ3z0LlA0jFS5H1RmWDETW270yF7g88sh3X','','','','','','','','','','test','buyer','','dikeooel3ski-buyer@gmail.com','CQXX6MYAKR3GJ',0,'','','',0,'5','Order 5','','TWD',593,20100,0,0,'',0,'','','verified','2017-08-21 13:09:02',NULL,'Completed','instant','','Ineligible',1,'',0,641,'USD',0,'Default',0,'','',NULL,0,0,0,0,0,NULL,0,'','','','','','','',NULL,0,0,0,0,0,0,'','','','','',0,'',NULL,NULL,NULL,'','',NULL,'','','','USD',0,'','127.0.0.1',0,'','','mc_gross=20100&invoice=5&settle_amount=640.92&protection_eligibility=Ineligible&payer_id=CQXX6MYAKR3GJ&tax=0&payment_date=06%3A09%3A02+Aug+21%2C+2017+PDT&payment_status=Completed&charset=windows-1252&first_name=test&mc_fee=593&exchange_rate=0.0328560&notify_version=3.8&custom=&settle_currency=USD&payer_status=verified&quantity=1&verify_sign=AGV6csTg6wZeXiLA3TJ1jLQ3z0LlA0jFS5H1RmWDETW270yF7g88sh3X&payer_email=dikeooel3ski-buyer%40gmail.com&txn_id=2KJ75079K5630732N&payment_type=instant&last_name=buyer&receiver_email=dikeooel3ski-facilitator%40gmail.com&payment_fee=&shipping_discount=0&insurance_amount=0&receiver_id=TMRXF6E4EKTM6&txn_type=web_accept&item_name=Order+5&discount=0&mc_currency=TWD&item_number=&residence_country=US&test_ipn=1&shipping_method=Default&handling_amount=0&transaction_subject=&payment_gross=&shipping=0&ipn_track_id=31f2c6d92cbf','VERIFIED','2017-08-21 13:11:45','2017-08-21 13:11:45',NULL,NULL,'','','web_accept');
/*!40000 ALTER TABLE `paypal_ipn` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shop_category`
--

DROP TABLE IF EXISTS `shop_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `shop_category` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_category`
--

LOCK TABLES `shop_category` WRITE;
/*!40000 ALTER TABLE `shop_category` DISABLE KEYS */;
INSERT INTO `shop_category` VALUES (1,'3C','3c'),(2,'book','book'),(3,'food','food'),(4,'daily necessity','daily-necessity');
/*!40000 ALTER TABLE `shop_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shop_product`
--

DROP TABLE IF EXISTS `shop_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `shop_product` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `image` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `stock` int(10) unsigned NOT NULL,
  `available` tinyint(1) NOT NULL,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_product`
--

LOCK TABLES `shop_product` WRITE;
/*!40000 ALTER TABLE `shop_product` DISABLE KEYS */;
INSERT INTO `shop_product` VALUES (1,'iphone','iphone','','iphone 7 Description ......',2000,122,1,'2017-08-20 14:10:20','2017-08-20 14:10:20',1),(2,'note8','note8','','note8 Description ......',200,133,1,'2017-08-20 14:10:59','2017-08-20 14:10:59',1),(3,'python tutorial','python-tutorial','','python is very good',500,111,1,'2017-08-20 14:12:10','2017-08-20 14:12:10',2),(4,'django awesome','django-awesome','','django is  awesome......',800,125,1,'2017-08-20 14:12:53','2017-08-20 14:12:53',2),(5,'hair dryer','hair-dryer','','hair dryer Description ......',600,24,1,'2017-08-20 14:14:17','2017-08-20 14:14:17',4),(6,'electric fan','electric-fan','','Electric fan Description ......',1200,32,1,'2017-08-20 14:15:17','2017-08-20 14:16:45',4),(7,'apple','apple','','apple is good',600,33,1,'2017-08-20 14:15:39','2017-08-20 14:15:39',3),(8,'banana','banana','','banana description ......',900,80,1,'2017-08-20 14:16:20','2017-08-20 14:16:20',3);
/*!40000 ALTER TABLE `shop_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'paytest'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-02-21  9:27:34
