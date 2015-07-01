-- MySQL dump 10.13  Distrib 5.6.24, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: userstyles
-- ------------------------------------------------------
-- Server version	5.6.24-0ubuntu2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `GDN_Activity`
--

DROP TABLE IF EXISTS `GDN_Activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Activity` (
  `ActivityID` int(11) NOT NULL AUTO_INCREMENT,
  `CommentActivityID` int(11) DEFAULT NULL,
  `ActivityTypeID` int(11) NOT NULL,
  `NotifyUserID` int(11) NOT NULL DEFAULT '0',
  `ActivityUserID` int(11) DEFAULT NULL,
  `RegardingUserID` int(11) DEFAULT NULL,
  `Photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `HeadlineFormat` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Story` mediumtext COLLATE utf8mb4_unicode_ci,
  `Format` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Route` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `RecordType` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `RecordID` int(11) DEFAULT NULL,
  `CountComments` int(11) NOT NULL DEFAULT '0',
  `InsertUserID` int(11) DEFAULT NULL,
  `DateInserted` datetime NOT NULL,
  `InsertIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DateUpdated` datetime NOT NULL,
  `Notified` tinyint(4) NOT NULL DEFAULT '0',
  `Emailed` tinyint(4) NOT NULL DEFAULT '0',
  `Data` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`ActivityID`),
  KEY `FK_Activity_CommentActivityID` (`CommentActivityID`),
  KEY `FK_Activity_InsertUserID` (`InsertUserID`),
  KEY `IX_Activity_Notify` (`NotifyUserID`,`Notified`),
  KEY `IX_Activity_Recent` (`NotifyUserID`,`DateUpdated`),
  KEY `IX_Activity_Feed` (`NotifyUserID`,`ActivityUserID`,`DateUpdated`),
  KEY `IX_Activity_DateUpdated` (`DateUpdated`)
) ENGINE=MyISAM AUTO_INCREMENT=175181 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_ActivityComment`
--

DROP TABLE IF EXISTS `GDN_ActivityComment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_ActivityComment` (
  `ActivityCommentID` int(11) NOT NULL AUTO_INCREMENT,
  `ActivityID` int(11) NOT NULL,
  `Body` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `Format` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `InsertUserID` int(11) NOT NULL,
  `DateInserted` datetime NOT NULL,
  `InsertIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`ActivityCommentID`),
  KEY `FK_ActivityComment_ActivityID` (`ActivityID`)
) ENGINE=InnoDB AUTO_INCREMENT=982 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_ActivityType`
--

DROP TABLE IF EXISTS `GDN_ActivityType`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_ActivityType` (
  `ActivityTypeID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `AllowComments` tinyint(4) NOT NULL DEFAULT '0',
  `ShowIcon` tinyint(4) NOT NULL DEFAULT '0',
  `ProfileHeadline` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `FullHeadline` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `RouteCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Notify` tinyint(4) NOT NULL DEFAULT '0',
  `Public` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ActivityTypeID`)
) ENGINE=MyISAM AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_AnalyticsLocal`
--

DROP TABLE IF EXISTS `GDN_AnalyticsLocal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_AnalyticsLocal` (
  `TimeSlot` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Views` int(11) DEFAULT NULL,
  `EmbedViews` int(11) DEFAULT NULL,
  UNIQUE KEY `UX_AnalyticsLocal` (`TimeSlot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_AntiSpam`
--

DROP TABLE IF EXISTS `GDN_AntiSpam`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_AntiSpam` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `StopForumSpam` tinyint(4) NOT NULL DEFAULT '1',
  `Akismet` tinyint(4) NOT NULL DEFAULT '0',
  `AkismetKey` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `DeleteSpam` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_AntiSpamLog`
--

DROP TABLE IF EXISTS `GDN_AntiSpamLog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_AntiSpamLog` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `UserID` int(11) NOT NULL,
  `Name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ForeignUrl` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ForeignID` int(11) NOT NULL,
  `ForeignType` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `IpAddress` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `DateInserted` datetime NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `FK_AntiSpamLog_UserID` (`UserID`),
  KEY `FK_AntiSpamLog_ForeignURL` (`ForeignUrl`)
) ENGINE=MyISAM AUTO_INCREMENT=675 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Ban`
--

DROP TABLE IF EXISTS `GDN_Ban`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Ban` (
  `BanID` int(11) NOT NULL AUTO_INCREMENT,
  `BanType` enum('IPAddress','Name','Email') COLLATE utf8mb4_unicode_ci NOT NULL,
  `BanValue` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Notes` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CountUsers` int(10) unsigned NOT NULL DEFAULT '0',
  `CountBlockedRegistrations` int(10) unsigned NOT NULL DEFAULT '0',
  `InsertUserID` int(11) NOT NULL,
  `DateInserted` datetime NOT NULL,
  `InsertIPAddress` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `UpdateUserID` int(11) DEFAULT NULL,
  `DateUpdated` datetime DEFAULT NULL,
  `UpdateIPAddress` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`BanID`),
  UNIQUE KEY `UX_Ban` (`BanType`,`BanValue`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Category`
--

DROP TABLE IF EXISTS `GDN_Category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Category` (
  `CategoryID` int(11) NOT NULL AUTO_INCREMENT,
  `ParentCategoryID` int(11) DEFAULT NULL,
  `TreeLeft` int(11) DEFAULT NULL,
  `TreeRight` int(11) DEFAULT NULL,
  `Depth` int(11) DEFAULT NULL,
  `CountDiscussions` int(11) NOT NULL DEFAULT '0',
  `CountComments` int(11) NOT NULL DEFAULT '0',
  `DateMarkedRead` datetime DEFAULT NULL,
  `AllowDiscussions` tinyint(4) NOT NULL DEFAULT '1',
  `Archived` tinyint(4) NOT NULL DEFAULT '0',
  `Name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `UrlCode` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Sort` int(11) DEFAULT NULL,
  `CssClass` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `PermissionCategoryID` int(11) NOT NULL DEFAULT '-1',
  `HideAllDiscussions` tinyint(4) NOT NULL DEFAULT '0',
  `DisplayAs` enum('Categories','Discussions','Default') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Default',
  `InsertUserID` int(11) NOT NULL,
  `UpdateUserID` int(11) DEFAULT NULL,
  `DateInserted` datetime NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `LastCommentID` int(11) DEFAULT NULL,
  `LastDiscussionID` int(11) DEFAULT NULL,
  `LastDateInserted` datetime DEFAULT NULL,
  `AllowFileUploads` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`CategoryID`),
  KEY `FK_Category_InsertUserID` (`InsertUserID`)
) ENGINE=MyISAM AUTO_INCREMENT=42236 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Comment`
--

DROP TABLE IF EXISTS `GDN_Comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Comment` (
  `CommentID` int(11) NOT NULL AUTO_INCREMENT,
  `DiscussionID` int(11) NOT NULL,
  `InsertUserID` int(11) DEFAULT NULL,
  `UpdateUserID` int(11) DEFAULT NULL,
  `DeleteUserID` int(11) DEFAULT NULL,
  `Body` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `Format` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DateInserted` datetime DEFAULT NULL,
  `DateDeleted` datetime DEFAULT NULL,
  `DateUpdated` datetime DEFAULT NULL,
  `InsertIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `UpdateIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Flag` tinyint(4) NOT NULL DEFAULT '0',
  `Score` float DEFAULT NULL,
  `Attributes` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`CommentID`),
  KEY `FK_Comment_InsertUserID` (`InsertUserID`),
  KEY `IX_Comment_1` (`DiscussionID`,`DateInserted`),
  KEY `IX_Comment_DateInserted` (`DateInserted`),
  FULLTEXT KEY `TX_Comment` (`Body`)
) ENGINE=MyISAM AUTO_INCREMENT=97331 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Conversation`
--

DROP TABLE IF EXISTS `GDN_Conversation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Conversation` (
  `ConversationID` int(11) NOT NULL AUTO_INCREMENT,
  `Subject` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Contributors` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `FirstMessageID` int(11) DEFAULT NULL,
  `InsertUserID` int(11) NOT NULL,
  `DateInserted` datetime DEFAULT NULL,
  `InsertIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `UpdateUserID` int(11) DEFAULT NULL,
  `DateUpdated` datetime DEFAULT NULL,
  `UpdateIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CountMessages` int(11) NOT NULL DEFAULT '0',
  `LastMessageID` int(11) DEFAULT NULL,
  `RegardingID` int(11) DEFAULT NULL,
  PRIMARY KEY (`ConversationID`),
  KEY `FK_Conversation_FirstMessageID` (`FirstMessageID`),
  KEY `FK_Conversation_InsertUserID` (`InsertUserID`),
  KEY `FK_Conversation_DateInserted` (`DateInserted`),
  KEY `FK_Conversation_UpdateUserID` (`UpdateUserID`),
  KEY `IX_Conversation_RegardingID` (`RegardingID`)
) ENGINE=MyISAM AUTO_INCREMENT=5878 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_ConversationMessage`
--

DROP TABLE IF EXISTS `GDN_ConversationMessage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_ConversationMessage` (
  `MessageID` int(11) NOT NULL AUTO_INCREMENT,
  `ConversationID` int(11) NOT NULL,
  `Body` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `Format` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `InsertUserID` int(11) DEFAULT NULL,
  `DateInserted` datetime NOT NULL,
  `InsertIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`MessageID`),
  KEY `FK_ConversationMessage_ConversationID` (`ConversationID`),
  KEY `FK_ConversationMessage_InsertUserID` (`InsertUserID`)
) ENGINE=MyISAM AUTO_INCREMENT=11385 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Discussion`
--

DROP TABLE IF EXISTS `GDN_Discussion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Discussion` (
  `DiscussionID` int(11) NOT NULL AUTO_INCREMENT,
  `Type` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ForeignID` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CategoryID` int(11) NOT NULL,
  `InsertUserID` int(11) NOT NULL,
  `UpdateUserID` int(11) DEFAULT NULL,
  `FirstCommentID` int(11) DEFAULT NULL,
  `LastCommentID` int(11) DEFAULT NULL,
  `Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Body` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `Format` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Tags` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CountComments` int(11) NOT NULL DEFAULT '0',
  `CountBookmarks` int(11) DEFAULT NULL,
  `CountViews` int(11) NOT NULL DEFAULT '1',
  `Closed` tinyint(4) NOT NULL DEFAULT '0',
  `Announce` tinyint(4) NOT NULL DEFAULT '0',
  `Sink` tinyint(4) NOT NULL DEFAULT '0',
  `DateInserted` datetime NOT NULL,
  `DateUpdated` datetime DEFAULT NULL,
  `InsertIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `UpdateIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DateLastComment` datetime DEFAULT NULL,
  `LastCommentUserID` int(11) DEFAULT NULL,
  `Score` float DEFAULT NULL,
  `Attributes` mediumtext COLLATE utf8mb4_unicode_ci,
  `RegardingID` int(11) DEFAULT NULL,
  `StyleID` int(11) DEFAULT NULL,
  `Rating` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`DiscussionID`),
  KEY `FK_Discussion_CategoryID` (`CategoryID`),
  KEY `FK_Discussion_InsertUserID` (`InsertUserID`),
  KEY `IX_Discussion_DateLastComment` (`DateLastComment`),
  KEY `IX_Discussion_Type` (`Type`),
  KEY `IX_Discussion_ForeignID` (`ForeignID`),
  KEY `IX_Discussion_RegardingID` (`RegardingID`),
  KEY `IX_Discussion_DateInserted` (`DateInserted`),
  KEY `IX_Discussion_CategoryPages` (`CategoryID`,`DateLastComment`),
  FULLTEXT KEY `TX_Discussion` (`Name`,`Body`)
) ENGINE=MyISAM AUTO_INCREMENT=45984 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Draft`
--

DROP TABLE IF EXISTS `GDN_Draft`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Draft` (
  `DraftID` int(11) NOT NULL AUTO_INCREMENT,
  `DiscussionID` int(11) DEFAULT NULL,
  `CategoryID` int(11) DEFAULT NULL,
  `InsertUserID` int(11) NOT NULL,
  `UpdateUserID` int(11) NOT NULL,
  `Name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Tags` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Closed` tinyint(4) NOT NULL DEFAULT '0',
  `Announce` tinyint(4) NOT NULL DEFAULT '0',
  `Sink` tinyint(4) NOT NULL DEFAULT '0',
  `Body` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `Format` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DateInserted` datetime NOT NULL,
  `DateUpdated` datetime DEFAULT NULL,
  PRIMARY KEY (`DraftID`),
  KEY `FK_Draft_DiscussionID` (`DiscussionID`),
  KEY `FK_Draft_CategoryID` (`CategoryID`),
  KEY `FK_Draft_InsertUserID` (`InsertUserID`)
) ENGINE=MyISAM AUTO_INCREMENT=47470 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Flag`
--

DROP TABLE IF EXISTS `GDN_Flag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Flag` (
  `InsertUserID` int(11) NOT NULL,
  `InsertName` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `AuthorID` int(11) NOT NULL,
  `AuthorName` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ForeignUrl` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ForeignID` int(11) NOT NULL,
  `ForeignType` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Comment` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `DateInserted` datetime NOT NULL,
  `DiscussionID` int(11) DEFAULT NULL,
  KEY `FK_Flag_InsertUserID` (`InsertUserID`),
  KEY `FK_Flag_ForeignURL` (`ForeignUrl`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Invitation`
--

DROP TABLE IF EXISTS `GDN_Invitation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Invitation` (
  `InvitationID` int(11) NOT NULL AUTO_INCREMENT,
  `Email` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `InsertUserID` int(11) DEFAULT NULL,
  `DateInserted` datetime NOT NULL,
  `AcceptedUserID` int(11) DEFAULT NULL,
  PRIMARY KEY (`InvitationID`),
  KEY `FK_Invitation_InsertUserID` (`InsertUserID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Log`
--

DROP TABLE IF EXISTS `GDN_Log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Log` (
  `LogID` int(11) NOT NULL AUTO_INCREMENT,
  `Operation` enum('Delete','Edit','Spam','Moderate','Pending','Ban','Error') COLLATE utf8mb4_unicode_ci NOT NULL,
  `RecordType` enum('Discussion','Comment','User','Registration','Activity','ActivityComment','Configuration','Group') COLLATE utf8mb4_unicode_ci NOT NULL,
  `TransactionLogID` int(11) DEFAULT NULL,
  `RecordID` int(11) DEFAULT NULL,
  `RecordUserID` int(11) DEFAULT NULL,
  `RecordDate` datetime NOT NULL,
  `RecordIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `InsertUserID` int(11) NOT NULL,
  `DateInserted` datetime NOT NULL,
  `InsertIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `OtherUserIDs` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DateUpdated` datetime DEFAULT NULL,
  `ParentRecordID` int(11) DEFAULT NULL,
  `CategoryID` int(11) DEFAULT NULL,
  `Data` longtext COLLATE utf8mb4_unicode_ci,
  `CountGroup` int(11) DEFAULT NULL,
  PRIMARY KEY (`LogID`),
  KEY `IX_Log_RecordType` (`RecordType`),
  KEY `IX_Log_RecordID` (`RecordID`),
  KEY `IX_Log_RecordIPAddress` (`RecordIPAddress`),
  KEY `IX_Log_ParentRecordID` (`ParentRecordID`),
  KEY `FK_Log_CategoryID` (`CategoryID`)
) ENGINE=InnoDB AUTO_INCREMENT=17366 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Media`
--

DROP TABLE IF EXISTS `GDN_Media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Media` (
  `MediaID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Type` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Size` int(11) NOT NULL,
  `ImageWidth` smallint(5) unsigned DEFAULT NULL,
  `ImageHeight` smallint(5) unsigned DEFAULT NULL,
  `ThumbWidth` smallint(5) unsigned DEFAULT NULL,
  `ThumbHeight` smallint(5) unsigned DEFAULT NULL,
  `ThumbPath` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `StorageMethod` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'local',
  `Path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `InsertUserID` int(11) NOT NULL,
  `DateInserted` datetime NOT NULL,
  `ForeignID` int(11) DEFAULT NULL,
  `ForeignTable` varchar(24) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`MediaID`)
) ENGINE=MyISAM AUTO_INCREMENT=10507 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Message`
--

DROP TABLE IF EXISTS `GDN_Message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Message` (
  `MessageID` int(11) NOT NULL AUTO_INCREMENT,
  `Content` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `Format` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `AllowDismiss` tinyint(4) NOT NULL DEFAULT '1',
  `Enabled` tinyint(4) NOT NULL DEFAULT '1',
  `Application` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Controller` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Method` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `AssetTarget` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CssClass` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Sort` int(11) DEFAULT NULL,
  PRIMARY KEY (`MessageID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Permission`
--

DROP TABLE IF EXISTS `GDN_Permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Permission` (
  `PermissionID` int(11) NOT NULL AUTO_INCREMENT,
  `RoleID` int(11) NOT NULL DEFAULT '0',
  `JunctionTable` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `JunctionColumn` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `JunctionID` int(11) DEFAULT NULL,
  `Garden.Settings.Manage` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Settings.View` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Messages.Manage` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.SignIn.Allow` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Applicants.Manage` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Users.Add` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Users.Edit` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Users.Delete` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Users.Approve` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Activity.Delete` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Activity.View` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Profiles.View` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Profiles.Edit` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Moderation.Manage` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Curation.Manage` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.PersonalInfo.View` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.AdvancedNotifications.Allow` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Discussions.View` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Discussions.Add` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Discussions.Edit` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Discussions.Announce` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Discussions.Sink` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Discussions.Close` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Discussions.Delete` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Comments.Add` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Comments.Edit` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Comments.Delete` tinyint(4) NOT NULL DEFAULT '0',
  `Plugins.Attachments.Upload.Allow` tinyint(4) NOT NULL DEFAULT '0',
  `Plugins.Attachments.Download.Allow` tinyint(4) NOT NULL DEFAULT '0',
  `Conversations.Moderation.Manage` tinyint(4) NOT NULL DEFAULT '0',
  `Conversations.Conversations.Add` tinyint(4) NOT NULL DEFAULT '0',
  `Garden.Email.View` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Approval.Require` tinyint(4) NOT NULL DEFAULT '0',
  `Vanilla.Comments.Me` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`PermissionID`),
  KEY `FK_Permission_RoleID` (`RoleID`)
) ENGINE=MyISAM AUTO_INCREMENT=95 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Photo`
--

DROP TABLE IF EXISTS `GDN_Photo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Photo` (
  `PhotoID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `InsertUserID` int(11) DEFAULT NULL,
  `DateInserted` datetime NOT NULL,
  PRIMARY KEY (`PhotoID`),
  KEY `FK_Photo_InsertUserID` (`InsertUserID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Regarding`
--

DROP TABLE IF EXISTS `GDN_Regarding`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Regarding` (
  `RegardingID` int(11) NOT NULL AUTO_INCREMENT,
  `Type` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `InsertUserID` int(11) NOT NULL,
  `DateInserted` datetime NOT NULL,
  `ForeignType` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ForeignID` int(11) NOT NULL,
  `OriginalContent` mediumtext COLLATE utf8mb4_unicode_ci,
  `ParentType` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ParentID` int(11) DEFAULT NULL,
  `ForeignURL` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Comment` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `Reports` int(11) DEFAULT NULL,
  PRIMARY KEY (`RegardingID`),
  KEY `FK_Regarding_Type` (`Type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Role`
--

DROP TABLE IF EXISTS `GDN_Role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Role` (
  `RoleID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Sort` int(11) DEFAULT NULL,
  `Deletable` tinyint(4) NOT NULL DEFAULT '1',
  `CanSession` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`RoleID`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Session`
--

DROP TABLE IF EXISTS `GDN_Session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Session` (
  `SessionID` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `UserID` int(11) NOT NULL DEFAULT '0',
  `DateInserted` datetime NOT NULL,
  `DateUpdated` datetime NOT NULL,
  `TransientKey` varchar(12) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Attributes` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`SessionID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Spammer`
--

DROP TABLE IF EXISTS `GDN_Spammer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Spammer` (
  `UserID` int(11) NOT NULL,
  `CountSpam` smallint(5) unsigned NOT NULL DEFAULT '0',
  `CountDeletedSpam` smallint(5) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`UserID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_Tag`
--

DROP TABLE IF EXISTS `GDN_Tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_Tag` (
  `TagID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Type` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `InsertUserID` int(11) DEFAULT NULL,
  `DateInserted` datetime NOT NULL,
  `CategoryID` int(11) NOT NULL DEFAULT '-1',
  `CountDiscussions` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`TagID`),
  UNIQUE KEY `UX_Tag` (`Name`,`CategoryID`),
  KEY `FK_Tag_InsertUserID` (`InsertUserID`),
  KEY `IX_Tag_Type` (`Type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_TagDiscussion`
--

DROP TABLE IF EXISTS `GDN_TagDiscussion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_TagDiscussion` (
  `TagID` int(11) NOT NULL,
  `DiscussionID` int(11) NOT NULL,
  `CategoryID` int(11) NOT NULL,
  `DateInserted` datetime NOT NULL,
  PRIMARY KEY (`TagID`,`DiscussionID`),
  KEY `IX_TagDiscussion_CategoryID` (`CategoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_User`
--

DROP TABLE IF EXISTS `GDN_User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_User` (
  `UserID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Password` varbinary(100) NOT NULL,
  `HashMethod` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Photo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Title` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `About` mediumtext COLLATE utf8mb4_unicode_ci,
  `Email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ShowEmail` tinyint(4) NOT NULL DEFAULT '0',
  `Gender` enum('u','m','f') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'u',
  `CountVisits` int(11) NOT NULL DEFAULT '0',
  `CountInvitations` int(11) NOT NULL DEFAULT '0',
  `CountNotifications` int(11) DEFAULT NULL,
  `InviteUserID` int(11) DEFAULT NULL,
  `DiscoveryText` mediumtext COLLATE utf8mb4_unicode_ci,
  `Preferences` mediumtext COLLATE utf8mb4_unicode_ci,
  `Permissions` mediumtext COLLATE utf8mb4_unicode_ci,
  `Attributes` mediumtext COLLATE utf8mb4_unicode_ci,
  `DateSetInvitations` datetime DEFAULT NULL,
  `DateOfBirth` datetime DEFAULT NULL,
  `DateFirstVisit` datetime DEFAULT NULL,
  `DateLastActive` datetime DEFAULT NULL,
  `LastIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `AllIPAddresses` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DateInserted` datetime NOT NULL,
  `InsertIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DateUpdated` datetime DEFAULT NULL,
  `UpdateIPAddress` varchar(39) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `HourOffset` int(11) NOT NULL DEFAULT '0',
  `Score` float DEFAULT NULL,
  `Admin` tinyint(4) NOT NULL DEFAULT '0',
  `Verified` tinyint(4) NOT NULL DEFAULT '0',
  `Banned` tinyint(4) NOT NULL DEFAULT '0',
  `Deleted` tinyint(4) NOT NULL DEFAULT '0',
  `Points` int(11) NOT NULL DEFAULT '0',
  `CountDiscussions` int(11) DEFAULT NULL,
  `CountUnreadDiscussions` int(11) DEFAULT NULL,
  `CountComments` int(11) DEFAULT NULL,
  `CountDrafts` int(11) DEFAULT NULL,
  `CountBookmarks` int(11) DEFAULT NULL,
  `CountUnreadConversations` int(11) DEFAULT NULL,
  `DateAllViewed` datetime DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  KEY `FK_User_Name` (`Name`),
  KEY `IX_User_Email` (`Email`),
  KEY `IX_User_DateLastActive` (`DateLastActive`),
  KEY `IX_User_DateInserted` (`DateInserted`)
) ENGINE=MyISAM AUTO_INCREMENT=163490 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserAuthentication`
--

DROP TABLE IF EXISTS `GDN_UserAuthentication`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserAuthentication` (
  `ForeignUserKey` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ProviderKey` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `UserID` int(11) NOT NULL,
  PRIMARY KEY (`ForeignUserKey`,`ProviderKey`),
  KEY `FK_UserAuthentication_UserID` (`UserID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserAuthenticationNonce`
--

DROP TABLE IF EXISTS `GDN_UserAuthenticationNonce`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserAuthenticationNonce` (
  `Nonce` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Token` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Nonce`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserAuthenticationProvider`
--

DROP TABLE IF EXISTS `GDN_UserAuthenticationProvider`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserAuthenticationProvider` (
  `AuthenticationKey` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `AuthenticationSchemeAlias` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `URL` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `AssociationSecret` mediumtext COLLATE utf8mb4_unicode_ci,
  `AssociationHashMethod` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `AuthenticateUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `RegisterUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `SignInUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `SignOutUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `PasswordUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ProfileUrl` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Attributes` mediumtext COLLATE utf8mb4_unicode_ci,
  `IsDefault` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`AuthenticationKey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserAuthenticationToken`
--

DROP TABLE IF EXISTS `GDN_UserAuthenticationToken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserAuthenticationToken` (
  `Token` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ProviderKey` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ForeignUserKey` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `TokenSecret` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `TokenType` enum('request','access') COLLATE utf8mb4_unicode_ci NOT NULL,
  `Authorized` tinyint(4) NOT NULL,
  `Timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Lifetime` int(11) NOT NULL,
  PRIMARY KEY (`Token`,`ProviderKey`),
  KEY `GDN_UserAuthenticationToken_ForeignUserKey` (`ForeignUserKey`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserCategory`
--

DROP TABLE IF EXISTS `GDN_UserCategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserCategory` (
  `UserID` int(11) NOT NULL,
  `CategoryID` int(11) NOT NULL,
  `DateMarkedRead` datetime DEFAULT NULL,
  `Unfollow` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`UserID`,`CategoryID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserComment`
--

DROP TABLE IF EXISTS `GDN_UserComment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserComment` (
  `UserID` int(11) NOT NULL,
  `CommentID` int(11) NOT NULL,
  `Score` float DEFAULT NULL,
  `DateLastViewed` datetime DEFAULT NULL,
  PRIMARY KEY (`UserID`,`CommentID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserConversation`
--

DROP TABLE IF EXISTS `GDN_UserConversation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserConversation` (
  `UserID` int(11) NOT NULL,
  `ConversationID` int(11) NOT NULL,
  `CountReadMessages` int(11) NOT NULL DEFAULT '0',
  `LastMessageID` int(11) DEFAULT NULL,
  `DateLastViewed` datetime DEFAULT NULL,
  `DateCleared` datetime DEFAULT NULL,
  `Bookmarked` tinyint(4) NOT NULL DEFAULT '0',
  `Deleted` tinyint(4) NOT NULL DEFAULT '0',
  `DateConversationUpdated` datetime DEFAULT NULL,
  PRIMARY KEY (`UserID`,`ConversationID`),
  KEY `FK_UserConversation_LastMessageID` (`LastMessageID`),
  KEY `IX_UserConversation_Inbox` (`UserID`,`Deleted`,`DateConversationUpdated`),
  KEY `FK_UserConversation_ConversationID` (`ConversationID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserDiscussion`
--

DROP TABLE IF EXISTS `GDN_UserDiscussion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserDiscussion` (
  `UserID` int(11) NOT NULL,
  `DiscussionID` int(11) NOT NULL,
  `Score` float DEFAULT NULL,
  `CountComments` int(11) NOT NULL DEFAULT '0',
  `DateLastViewed` datetime DEFAULT NULL,
  `Dismissed` tinyint(4) NOT NULL DEFAULT '0',
  `Bookmarked` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`UserID`,`DiscussionID`),
  KEY `FK_UserDiscussion_DiscussionID` (`DiscussionID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserMerge`
--

DROP TABLE IF EXISTS `GDN_UserMerge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserMerge` (
  `MergeID` int(11) NOT NULL AUTO_INCREMENT,
  `OldUserID` int(11) NOT NULL,
  `NewUserID` int(11) NOT NULL,
  `DateInserted` datetime NOT NULL,
  `InsertUserID` int(11) NOT NULL,
  `DateUpdated` datetime DEFAULT NULL,
  `UpdateUserID` int(11) DEFAULT NULL,
  `Attributes` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`MergeID`),
  KEY `FK_UserMerge_OldUserID` (`OldUserID`),
  KEY `FK_UserMerge_NewUserID` (`NewUserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserMergeItem`
--

DROP TABLE IF EXISTS `GDN_UserMergeItem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserMergeItem` (
  `MergeID` int(11) NOT NULL,
  `Table` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Column` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `RecordID` int(11) NOT NULL,
  `OldUserID` int(11) NOT NULL,
  `NewUserID` int(11) NOT NULL,
  KEY `FK_UserMergeItem_MergeID` (`MergeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserMeta`
--

DROP TABLE IF EXISTS `GDN_UserMeta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserMeta` (
  `UserID` int(11) NOT NULL,
  `Name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Value` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`UserID`,`Name`),
  KEY `IX_UserMeta_Name` (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserPoints`
--

DROP TABLE IF EXISTS `GDN_UserPoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserPoints` (
  `SlotType` enum('d','w','m','y','a') COLLATE utf8mb4_unicode_ci NOT NULL,
  `TimeSlot` datetime NOT NULL,
  `Source` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Total',
  `UserID` int(11) NOT NULL,
  `Points` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`SlotType`,`TimeSlot`,`Source`,`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `GDN_UserRole`
--

DROP TABLE IF EXISTS `GDN_UserRole`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `GDN_UserRole` (
  `UserID` int(11) NOT NULL,
  `RoleID` int(11) NOT NULL,
  PRIMARY KEY (`UserID`,`RoleID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_delete_reasons`
--

DROP TABLE IF EXISTS `admin_delete_reasons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_delete_reasons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reason` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `locked` tinyint(1) NOT NULL DEFAULT '0',
  `default_message` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `daily_install_counts`
--

DROP TABLE IF EXISTS `daily_install_counts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `daily_install_counts` (
  `style_id` int(11) NOT NULL,
  `source` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_style_source_and_ip` (`style_id`,`ip`,`source`),
  KEY `daily_install_counts_date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `daily_report_counts`
--

DROP TABLE IF EXISTS `daily_report_counts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `daily_report_counts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `style_id` int(11) NOT NULL,
  `ip` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_daily_report_counts_on_style_id_and_ip` (`style_id`,`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=27883 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delayed_jobs`
--

DROP TABLE IF EXISTS `delayed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` mediumtext COLLATE utf8mb4_unicode_ci,
  `last_error` mediumtext COLLATE utf8mb4_unicode_ci,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2109117 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `precalculated_warnings`
--

DROP TABLE IF EXISTS `precalculated_warnings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `precalculated_warnings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `style_id` int(11) NOT NULL,
  `warning_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `detail` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_precalculated_warnings_on_style_id` (`style_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14383 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `screenshots`
--

DROP TABLE IF EXISTS `screenshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `screenshots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `style_id` int(11) NOT NULL,
  `description` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `path` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `style_id` (`style_id`)
) ENGINE=MyISAM AUTO_INCREMENT=15232 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `style_codes`
--

DROP TABLE IF EXISTS `style_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `style_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `style_id` int(11) NOT NULL DEFAULT '0',
  `code` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `style_id` (`style_id`)
) ENGINE=MyISAM AUTO_INCREMENT=114419 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `style_install_counts`
--

DROP TABLE IF EXISTS `style_install_counts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `style_install_counts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `style_id` int(11) NOT NULL DEFAULT '0',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `install_count` int(11) NOT NULL DEFAULT '0',
  `source` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  UNIQUE KEY `unique_style_source_and_date` (`style_id`,`date`,`source`),
  KEY `id` (`id`),
  KEY `style_id` (`style_id`),
  KEY `date` (`date`)
) ENGINE=MyISAM AUTO_INCREMENT=35110413 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `style_section_rules`
--

DROP TABLE IF EXISTS `style_section_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `style_section_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `style_section_id` int(11) NOT NULL,
  `rule_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rule_value` varchar(1000) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `style_section_rules_style_section_id` (`style_section_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2069331 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `style_sections`
--

DROP TABLE IF EXISTS `style_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `style_sections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `style_id` int(11) NOT NULL,
  `ordinal` int(11) NOT NULL,
  `global` tinyint(1) NOT NULL,
  `css` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `style_sections_style_id` (`style_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1305185 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `style_setting_options`
--

DROP TABLE IF EXISTS `style_setting_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `style_setting_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `style_setting_id` int(11) NOT NULL,
  `label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `default` tinyint(1) NOT NULL DEFAULT '0',
  `ordinal` int(11) NOT NULL,
  `install_key` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_style_setting_id_install_key` (`style_setting_id`,`install_key`),
  KEY `style_option_values_style_option_id` (`style_setting_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1615282 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `style_settings`
--

DROP TABLE IF EXISTS `style_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `style_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `style_id` int(11) NOT NULL,
  `install_key` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ordinal` int(11) DEFAULT NULL,
  `setting_type` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ix_style_options_style_id_name` (`style_id`,`install_key`)
) ENGINE=MyISAM AUTO_INCREMENT=445307 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `styles`
--

DROP TABLE IF EXISTS `styles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `styles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `short_description` varchar(75) COLLATE utf8mb4_unicode_ci NOT NULL,
  `long_description` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `obsolete` tinyint(4) NOT NULL DEFAULT '0',
  `obsoleting_style_id` int(11) DEFAULT NULL,
  `obsoletion_message` longtext COLLATE utf8mb4_unicode_ci,
  `created` datetime NOT NULL,
  `updated` datetime NOT NULL,
  `before_screenshot_name` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `after_screenshot_name` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subcategory` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `userjs_available` tinyint(1) NOT NULL DEFAULT '0',
  `total_install_count` int(11) DEFAULT '0',
  `weekly_install_count` int(11) DEFAULT '0',
  `allow_long_code` tinyint(4) NOT NULL DEFAULT '0',
  `forum_category_id` int(11) DEFAULT NULL,
  `redirect_page` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opera_css_available` tinyint(1) NOT NULL DEFAULT '0',
  `popularity_score` int(11) NOT NULL DEFAULT '0',
  `rating` float(2,1) DEFAULT NULL,
  `ie_css_available` tinyint(1) NOT NULL DEFAULT '0',
  `chrome_json_available` tinyint(1) DEFAULT '0',
  `screenshot_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `screenshot_url_override` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `screenshot_type_preference` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'auto',
  `pledgie_id` int(11) DEFAULT NULL,
  `additional_info` longtext COLLATE utf8mb4_unicode_ci,
  `auto_screenshot_date` datetime DEFAULT NULL,
  `auto_screenshot_last_failure_date` datetime DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `license` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `code_error` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `auto_screenshots_same` tinyint(1) NOT NULL DEFAULT '0',
  `unintentional_global` tinyint(1) NOT NULL DEFAULT '0',
  `admin_delete_reason_id` int(11) DEFAULT NULL,
  `moz_doc_error` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `md5` char(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `obsolete` (`obsolete`),
  KEY `created` (`created`),
  KEY `updated` (`updated`),
  KEY `short_description` (`short_description`),
  KEY `category` (`category`),
  KEY `user_id` (`user_id`),
  KEY `subcategory` (`subcategory`),
  KEY `popularity_score` (`popularity_score`),
  KEY `admin_delete_reason_id` (`admin_delete_reason_id`)
) ENGINE=InnoDB AUTO_INCREMENT=114203 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_authenticators`
--

DROP TABLE IF EXISTS `user_authenticators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_authenticators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `provider` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_identifier` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `provider_identifier` (`provider_identifier`),
  KEY `user_id_fk` (`user_id`),
  KEY `provider_provider_identifier_ix` (`provider`,`provider_identifier`)
) ENGINE=MyISAM AUTO_INCREMENT=84325 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `show_ads` tinyint(1) NOT NULL DEFAULT '0',
  `token` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `openid_url` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `LUM_User_id` int(10) DEFAULT NULL,
  `paypal_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hashed_password` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `salt` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lost_password_key` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `show_email` tinyint(1) NOT NULL DEFAULT '0',
  `homepage` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `about` longtext COLLATE utf8mb4_unicode_ci,
  `license` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_login_unique` (`login`,`openid_url`),
  UNIQUE KEY `unique_login` (`login`),
  KEY `token` (`token`),
  KEY `LUM_User_id` (`LUM_User_id`)
) ENGINE=MyISAM AUTO_INCREMENT=292057 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-06-30 22:22:53
INSERT INTO schema_migrations (version) VALUES ('20111007022556');

INSERT INTO schema_migrations (version) VALUES ('20131104171052');

INSERT INTO schema_migrations (version) VALUES ('20141005210800');

INSERT INTO schema_migrations (version) VALUES ('20141106175043');

INSERT INTO schema_migrations (version) VALUES ('20150523041432');

INSERT INTO schema_migrations (version) VALUES ('20150701025820');

INSERT INTO schema_migrations (version) VALUES ('6');

