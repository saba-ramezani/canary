-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 14, 2021 at 05:31 PM
-- Server version: 10.4.19-MariaDB
-- PHP Version: 8.0.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `canary`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Block` (IN `blockeeUsernameIn` VARCHAR(20))  BEGIN
	INSERT INTO `blocks`(`BLOCKER_USERNAME`, `BLOCKEE_USERNAME`)
    (SELECT username,blockeeUsernameIn
     from login_log
     ORDER by login_log.LOGIN_TIME DESC
     LIMIT 1);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Follow` (IN `followedUsernameIn` VARCHAR(20))  BEGIN
	INSERT INTO `follows`(`FOLLOWER_USERNAME`, `FOLLOWED_USERNAME`)
    (select username,followedUsernameIn
     from login_log
     order by login_log.LOGIN_TIME DESC
     LIMIT 1);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetComments` (IN `parentTweetIdIn` INT(6))  BEGIN
	select *
	from tweet
	where PARENT_TWEET_ID = parentTweetIdIn and (SELECT tweet.sender_username,login_log.USERNAME
                                                 from login_log
                                                 ORDER BY login_log.LOGIN_TIME DESC
                                                 limit 1) not in (select * from blocks) and 
	not exists (select *
                from blocks
                where blocker_username = (select tweet.sender_username
                                      	  from tweet
                                          where tweet.id = parentTweetIdIn)
                and blockee_username = (SELECT login_log.USERNAME
                                       from login_log
                                       ORDER BY login_log.LOGIN_TIME DESC
                                       limit 1));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFollowingsActivity` ()  BEGIN
	select tweet.* 
	from follows join tweet on (followed_username = sender_username)
	where follower_username = (select login_log.USERNAME
                               from login_log
                               ORDER BY login_log.LOGIN_TIME DESC
                               limit 1)
          and (SELECT tweet.SENDER_USERNAME,login_log.USERNAME
               from login_log 
               ORDER by login_log.LOGIN_TIME DESC
               LIMIT 1) not in (select * from blocks)
		  and tweet.PARENT_TWEET_ID is null
	order by tweet.SEND_DATE DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLikesCount` (IN `tweetIdIn` INT(6))  BEGIN
	select count(USERNAME) as likes_count
	from likes join tweet on (TWEET_ID = ID)
	where TWEET_ID = tweetIdIn and (SELECT sender_username,username
                                    from login_log
                                    ORDER by login_log.LOGIN_TIME DESC
                                    LIMIT 1) not in (SELECT * from blocks);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLikesList` (IN `TweetIdIn` INT(6))  BEGIN
	select USERNAME
	from likes join tweet on (TWEET_ID = ID)
	where TWEET_ID = TweetIdIn and (SELECT sender_username,login_log.username
                                    from login_log
                                    ORDER by login_log.LOGIN_TIME DESC
                                    LIMIT 1) not in (SELECT * from blocks) and
                                   (SELECT likes.USERNAME,login_log.username
                                    from login_log
                                    ORDER by login_log.LOGIN_TIME DESC
                                    LIMIT 1) not in (select * from blocks);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLoginsList` (IN `usernameIn` VARCHAR(20))  BEGIN
	SELECT LOGIN_TIME
	FROM login_log
	WHERE USERNAME = usernameIn
	ORDER by LOGIN_TIME DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMessageSendersList` ()  BEGIN
	with inputs(loginUsername) as (select login_log.USERNAME
                               from login_log
                               ORDER by login_log.LOGIN_TIME DESC
                               LIMIT 1)
	select DISTINCT message.SENDER_USERNAME
	from MESSAGE left outer join tweet on (TWEET_ID = tweet.ID),inputs
	WHERE message.RECEIVER_USERNAME = inputs.loginUsername and 
	(TWEET_ID is null or (tweet.SENDER_USERNAME, inputs.loginUsername) not in (SELECT * from blocks))
	order by TIME_SENT DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPersonalTweets` ()  BEGIN
	select * 
	from tweet
	where sender_username = (SELECT login_log.USERNAME
                             from login_log
                             ORDER by login_log.LOGIN_TIME DESC
                             limit 1);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPopularTweets` ()  BEGIN
	select tweet.* , count(USERNAME) as likes_count 
	from likes RIGHT OUTER join tweet on (TWEET_ID = ID)
	where (SELECT tweet.SENDER_USERNAME,login_log.USERNAME
           from login_log
           order by login_log.LOGIN_TIME DESC
           limit 1) not in (SELECT * from blocks) and parent_tweet_id is null
	group by ID
	order by likes_count DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetTweetsOfHashtag` (IN `hashtagIn` VARCHAR(6))  BEGIN
select tweet.*
    from tweet_hashtag join tweet on (tweet_hashtag.tweet_id = tweet.id)
    where tweet_hashtag.label = hashtagIn and not EXISTS (SELECT * 
                                                         from blocks
                                                         where blocks.BLOCKER_USERNAME=tweet.SENDER_USERNAME
                                                         and blocks.BLOCKEE_USERNAME=(SELECT login_log.USERNAME
                                                                                    from login_log
                                                                                    order by login_log.LOGIN_TIME DESC
                                                                                    limit 1));
End$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserActivity` (IN `targetUserIn` VARCHAR(20))  BEGIN
	select tweet.* 
	from tweet
	where sender_username = targetUserIn and (SELECT tweet.SENDER_USERNAME,login_log.USERNAME
                                              from login_log
                                              order by login_log.LOGIN_TIME DESC
                                              limit 1) not in (select * from blocks)
order by tweet.SEND_DATE DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserMessages` (IN `targetUsernameIn` VARCHAR(20))  BEGIN
	with inputs(username, loginUsername) as (select targetUsernameIn,login_log.USERNAME
                                             from login_log
                                             order by login_log.LOGIN_TIME DESC
                                             limit 1)
	select message.*
	from MESSAGE left outer join tweet on (TWEET_ID = tweet.ID),inputs
	WHERE message.SENDER_USERNAME = inputs.username and message.RECEIVER_USERNAME = inputs.loginUsername and 
	(TWEET_ID is null or (tweet.SENDER_USERNAME, inputs.loginUsername) not in (SELECT * from blocks))
	order by TIME_SENT DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GiveComment` (IN `commentContentIn` VARCHAR(256), IN `parentTweetIdIn` INT(6))  BEGIN
	INSERT INTO `tweet`(`CONTENT`, `PARENT_TWEET_ID`, `SENDER_USERNAME`) 
	select distinct commentContentIn, parentTweetIdIn , (SELECT login_log.USERNAME
                                                         from login_log
                                                         ORDER BY login_log.LOGIN_TIME DESC
                                                         LIMIT 1)
    from tweet
    where tweet.ID = parentTweetIdIn and (SELECT tweet.SENDER_USERNAME,login_log.USERNAME
                                          from login_log
                                          order by login_log.LOGIN_TIME DESC
                                          limit 1) not in (SELECT * from blocks);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LikeTweet` (IN `tweetIdIn` INT(6))  BEGIN
	INSERT INTO `likes`(`TWEET_ID`, `USERNAME`) 
	select tweetIdIn, (SELECT login_log.USERNAME
                       from login_log
                       order by login_log.LOGIN_TIME DESC
                       limit 1)
	from tweet
	where tweet.id = tweetIdIn and (SELECT tweet.SENDER_USERNAME,login_log.USERNAME
                                    from login_log
                                    order by login_log.LOGIN_TIME DESC
                                    limit 1) not IN (select * from blocks);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Login` (IN `usernameIn` VARCHAR(20), IN `passwordIn` VARCHAR(128))  BEGIN
	INSERT INTO login_log
	(SELECT USERNAME, CURRENT_TIMESTAMP FROM users
 	WHERE USERNAME = usernameIn AND HASHED_PASSWORD = PASSWORD(passwordIn));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `NewTweet` (IN `contentIn` VARCHAR(256))  BEGIN
	INSERT INTO `tweet`(`CONTENT`, `SENDER_USERNAME`) 
    (select contentIn, login_log.USERNAME
     from login_log
     ORDER BY login_log.LOGIN_TIME DESC
     limit 1);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Register` (IN `UsernameIn` VARCHAR(20), IN `FirstNameIn` VARCHAR(20), IN `LastNameIn` VARCHAR(20), IN `Hashed_PasswordIn` VARCHAR(128), IN `BirthdateIn` VARCHAR(10), IN `BiographyIn` VARCHAR(64))  BEGIN
	INSERT INTO `users`(`USERNAME`, `FIRSTNAME`, `LASTNAME`, `HASHED_PASSWORD`, `BIRTHDATE`, `BIOGRAPHY`) VALUES 						(UsernameIn,FirstNameIn,LastNameIn,PASSWORD(Hashed_passwordIn), STR_TO_DATE(BirthdateIn,'%d/%m/%Y'),BiographyIn);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SendMessage` (IN `receiverUsernameIn` VARCHAR(20), IN `tweetIdIn` INT(6), IN `messageTextIn` VARCHAR(256))  BEGIN
	INSERT INTO `message`(`SENDER_USERNAME`, `RECEIVER_USERNAME`, `TWEET_ID`, `MESSAGE_CONTENT`)
	with inputs(sender,receiver,tweet_id,message) as (
    select login_log.username,receiverUsernameIn,tweetIdIn,messageTextIn 
    from login_log
    order by login_log.LOGIN_TIME DESC
    limit 1)
	SELECT DISTINCT INPUTS.* 
	FROM INPUTS left outer JOIN tweet ON (INPUTS.TWEET_ID=TWEET.ID)
	WHERE (RECEIVER,SENDER) NOT IN (SELECT * FROM BLOCKS)
	AND (inputs.tweet_id is null or (SENDER_USERNAME,SENDER) NOT IN (SELECT * FROM BLOCKS));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Unblock` (IN `blockeeUsernameIn` VARCHAR(20))  BEGIN
	DELETE FROM `blocks`
	WHERE (BLOCKER_USERNAME, BLOCKEE_USERNAME) =
    (SELECT username,blockeeUsernameIn
     from login_log
     ORDER by login_log.LOGIN_TIME DESC
     LIMIT 1);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Unfollow` (IN `followedUsernameIn` VARCHAR(20))  BEGIN
	delete from follows
	where (follower_username, followed_username) = (SELECT username,followedUsernameIn
                                                    from login_log
                                                    ORDER by login_log.LOGIN_TIME DESC
                                                    LIMIT 1);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `blocks`
--

CREATE TABLE `blocks` (
  `BLOCKER_USERNAME` varchar(20) NOT NULL,
  `BLOCKEE_USERNAME` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `blocks`
--

INSERT INTO `blocks` (`BLOCKER_USERNAME`, `BLOCKEE_USERNAME`) VALUES
('user3', 'user1'),
('user6', 'user2');

-- --------------------------------------------------------

--
-- Table structure for table `follows`
--

CREATE TABLE `follows` (
  `FOLLOWER_USERNAME` varchar(20) NOT NULL,
  `FOLLOWED_USERNAME` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `follows`
--

INSERT INTO `follows` (`FOLLOWER_USERNAME`, `FOLLOWED_USERNAME`) VALUES
('user1', 'user2'),
('user1', 'user3'),
('user1', 'user4'),
('user1', 'user5'),
('user2', 'user1'),
('user2', 'user3');

-- --------------------------------------------------------

--
-- Table structure for table `hashtag`
--

CREATE TABLE `hashtag` (
  `LABEL` char(6) NOT NULL
) ;

--
-- Dumping data for table `hashtag`
--

INSERT INTO `hashtag` (`LABEL`) VALUES
('#abcda'),
('#abcdc'),
('#abcde'),
('#sabas');

-- --------------------------------------------------------

--
-- Table structure for table `likes`
--

CREATE TABLE `likes` (
  `TWEET_ID` int(6) NOT NULL,
  `USERNAME` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `likes`
--

INSERT INTO `likes` (`TWEET_ID`, `USERNAME`) VALUES
(1, 'user2'),
(1, 'user3'),
(2, 'user1'),
(3, 'user1'),
(4, 'user1'),
(5, 'user1'),
(5, 'user2'),
(5, 'user5'),
(5, 'user6'),
(5, 'user7'),
(5, 'user8');

-- --------------------------------------------------------

--
-- Table structure for table `login_log`
--

CREATE TABLE `login_log` (
  `USERNAME` varchar(20) NOT NULL,
  `LOGIN_TIME` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `login_log`
--

INSERT INTO `login_log` (`USERNAME`, `LOGIN_TIME`) VALUES
('user1', '2021-05-25 19:49:42'),
('user1', '2021-05-25 19:54:56'),
('user1', '2021-05-25 19:55:08'),
('user1', '2021-07-13 13:12:21'),
('user1', '2021-07-14 12:30:22'),
('user1', '2021-07-14 13:23:36'),
('user2', '2021-05-25 19:54:56'),
('user2', '2021-05-25 19:55:08'),
('user2', '2021-07-13 23:59:19'),
('user2', '2021-07-14 13:22:54');

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `ID` int(6) NOT NULL,
  `SENDER_USERNAME` varchar(20) NOT NULL,
  `RECEIVER_USERNAME` varchar(20) NOT NULL,
  `TWEET_ID` int(6) DEFAULT NULL,
  `MESSAGE_CONTENT` varchar(256) DEFAULT NULL,
  `TIME_SENT` timestamp NOT NULL DEFAULT current_timestamp()
) ;

--
-- Dumping data for table `message`
--

INSERT INTO `message` (`ID`, `SENDER_USERNAME`, `RECEIVER_USERNAME`, `TWEET_ID`, `MESSAGE_CONTENT`, `TIME_SENT`) VALUES
(1, 'user1', 'user2', 1, NULL, '2021-05-28 14:29:47'),
(2, 'user1', 'user2', NULL, 'hhh', '2021-05-28 14:35:59'),
(3, 'user1', 'user2', 2, NULL, '2021-05-28 14:36:18'),
(4, 'user1', 'user2', 1, NULL, '2021-05-28 14:37:57'),
(5, 'user2', 'user1', 1, NULL, '2021-05-28 14:58:40'),
(6, 'user2', 'user1', 5, NULL, '2021-05-28 14:58:46'),
(7, 'user3', 'user2', 1, NULL, '2021-05-28 15:36:26'),
(8, 'user4', 'user2', 1, NULL, '2021-05-28 15:36:32'),
(9, 'user4', 'user2', NULL, 'hey', '2021-05-28 15:36:49'),
(10, 'user5', 'user2', NULL, 'bye', '2021-05-28 15:36:59'),
(11, 'user5', 'user2', 2, NULL, '2021-05-28 15:37:17'),
(12, 'user1', 'user2', 1, NULL, '2021-07-13 14:11:35'),
(13, 'user1', 'user2', NULL, 'salap', '2021-07-13 14:14:27'),
(14, 'user2', 'user2', 1, NULL, '2021-07-14 00:16:28'),
(15, 'user1', 'user2', NULL, 'slm', '2021-07-14 14:09:55'),
(16, 'user1', 'user2', 1, NULL, '2021-07-14 14:10:29'),
(17, 'user1', 'user2', 1, NULL, '2021-07-14 14:20:36'),
(18, 'user1', 'user2', NULL, 'slmmmmmm chtoriiii ch khbrrrr ', '2021-07-14 14:21:11');

-- --------------------------------------------------------

--
-- Table structure for table `new_tweets`
--

CREATE TABLE `new_tweets` (
  `ID` int(6) NOT NULL,
  `SENDER_USERNAME` varchar(20) NOT NULL,
  `SEND_DATE` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `new_tweets`
--

INSERT INTO `new_tweets` (`ID`, `SENDER_USERNAME`, `SEND_DATE`) VALUES
(21, 'user1', '2021-07-13 19:56:59'),
(22, 'user1', '2021-07-13 23:48:10'),
(23, 'user1', '2021-07-13 23:53:11'),
(24, 'user2', '2021-07-14 00:01:53'),
(25, 'user1', '2021-07-14 13:32:55'),
(26, 'user1', '2021-07-14 13:34:24'),
(29, 'user1', '2021-07-14 14:57:28'),
(30, 'user1', '2021-07-14 14:58:26');

-- --------------------------------------------------------

--
-- Table structure for table `new_users`
--

CREATE TABLE `new_users` (
  `NewUsername` varchar(20) NOT NULL,
  `NewRegistrationDate` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `new_users`
--

INSERT INTO `new_users` (`NewUsername`, `NewRegistrationDate`) VALUES
('user10', '2021-07-13 19:44:04'),
('user11', '2021-07-14 00:09:11'),
('username20', '2021-07-14 13:35:17');

-- --------------------------------------------------------

--
-- Table structure for table `tweet`
--

CREATE TABLE `tweet` (
  `ID` int(6) NOT NULL,
  `CONTENT` varchar(256) NOT NULL,
  `PARENT_TWEET_ID` int(6) DEFAULT NULL,
  `SENDER_USERNAME` varchar(20) NOT NULL,
  `SEND_DATE` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `tweet`
--

INSERT INTO `tweet` (`ID`, `CONTENT`, `PARENT_TWEET_ID`, `SENDER_USERNAME`, `SEND_DATE`) VALUES
(1, 'tweet 1', NULL, 'user1', '2021-05-25 20:02:09'),
(2, 'tweet 1', NULL, 'user2', '2021-05-25 21:16:36'),
(3, 'tweet 2', NULL, 'user2', '2021-05-25 21:16:51'),
(4, 'tweet 3', NULL, 'user2', '2021-05-25 21:17:09'),
(5, 'tweet 1', NULL, 'user3', '2021-05-25 21:17:23'),
(6, 'comment 1', 1, 'user2', '2021-05-25 22:00:14'),
(7, 'comment 1', 1, 'user2', '2021-05-25 22:02:08'),
(8, 'comment 1', 3, 'user1', '2021-05-25 22:06:17'),
(9, 'comment 1', 3, 'user3', '2021-05-25 22:06:27'),
(10, 'comment 1', 3, 'user4', '2021-05-25 22:06:37'),
(11, 'comment 1', 5, 'user2', '2021-05-25 22:08:06'),
(12, 'nice', 2, 'user1', '2021-07-13 14:43:56'),
(13, 'nice', 2, 'user2', '2021-07-13 14:43:56'),
(15, 'noooo', 2, 'user1', '2021-07-13 14:46:42'),
(16, 'noooo', 2, 'user2', '2021-07-13 14:46:42'),
(18, 'like', 2, 'user2', '2021-07-13 14:50:37'),
(19, 'yeah', 2, 'user1', '2021-07-13 14:54:48'),
(20, 'good morning', NULL, 'user1', '2021-07-13 19:50:21'),
(21, 'gnnnn', NULL, 'user1', '2021-07-13 19:56:59'),
(22, 'noice', 3, 'user1', '2021-07-13 23:48:10'),
(23, 'noice', 3, 'user1', '2021-07-13 23:53:11'),
(24, 'hello world!', NULL, 'user2', '2021-07-14 00:01:53'),
(25, 'good one bro ', 1, 'user1', '2021-07-14 13:32:55'),
(26, 'hello everyone and gm ', NULL, 'user1', '2021-07-14 13:34:24'),
(29, 'salam #sabas', NULL, 'user1', '2021-07-14 14:57:28'),
(30, 'bye #sabas', NULL, 'user1', '2021-07-14 14:58:26');

--
-- Triggers `tweet`
--
DELIMITER $$
CREATE TRIGGER `FindHashtag` AFTER INSERT ON `tweet` FOR EACH ROW BEGIN
SET @s=NEW.content;
SET @flag=100;
while @flag>0 DO
    SET @hashtagLocation=INSTR(@s,'#'); /*find location of hashtag*/
    IF @hashtagLocation<=0 THEN
        SET @flag=0;
    END IF;
    IF @hashtagLocation>0 THEN
        set @hashtagText=SUBSTRING(@s,@hashtagLocation,6);
        set @nextChar=SUBSTRING(@s,@hashtagLocation+6,1);
         /*insert hashtag to tweet_hashtag*/
        IF @hashtagText REGEXP "#[A-Z][A-Z][A-Z][A-Z][A-Z]" and @nextChar=' ' then
        INSERT INTO hashtag(hashtag.LABEL) 
        SELECT @hashtagText
        where @hashtagText not in (select * from hashtag);
        INSERT INTO tweet_hashtag(TWEET_ID,LABEL) VALUES (NEW.ID,@hashtagText);
        END IF;
   END IF;
   SET @s=SUBSTRING(@s,@hashtagLocation+6,256);
END WHILE;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_tweet_insert` AFTER INSERT ON `tweet` FOR EACH ROW insert into new_tweets VALUES
    (new.id,new.sender_username,new.send_date)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tweet_hashtag`
--

CREATE TABLE `tweet_hashtag` (
  `TWEET_ID` int(6) NOT NULL,
  `LABEL` char(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `tweet_hashtag`
--

INSERT INTO `tweet_hashtag` (`TWEET_ID`, `LABEL`) VALUES
(3, '#abcda'),
(3, '#abcde'),
(5, '#abcdc'),
(7, '#abcde'),
(29, '#sabas'),
(30, '#sabas');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `USERNAME` varchar(20) NOT NULL,
  `FIRSTNAME` varchar(20) NOT NULL,
  `LASTNAME` varchar(20) NOT NULL,
  `HASHED_PASSWORD` varchar(128) NOT NULL,
  `BIRTHDATE` date NOT NULL,
  `BIOGRAPHY` varchar(64) NOT NULL,
  `REGISTERATION_DATE` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`USERNAME`, `FIRSTNAME`, `LASTNAME`, `HASHED_PASSWORD`, `BIRTHDATE`, `BIOGRAPHY`, `REGISTERATION_DATE`) VALUES
('user1', 'a', 'aa', '*668425423DB5193AF921380129F465A6425216D0', '2013-05-21', 'test object 1!', '2021-05-25 19:36:38'),
('user10', '10', '1000', '*EEA3D5BA534EA1FCD22E64C61E8D59132ADF346B', '2022-12-20', 'subject 10', '2021-07-13 19:44:04'),
('user11', '11', '1111', '*E414A7D17839E0F29789CAD8E2F1706C1F43D4C7', '2020-12-18', 'im 20', '2021-07-14 00:09:11'),
('user2', 'b', 'bb', '*DC52755F3C09F5923046BD42AFA76BD1D80DF2E9', '2012-05-15', 'test object 2!', '2021-05-25 19:36:38'),
('user3', 'c', 'cc', '*40C3E7D386A2FADBDF69ACEBE7AA4DC3C723D798', '2011-08-11', 'test object 3!', '2021-05-25 19:36:38'),
('user4', 'd', 'dd', '*F97AEB38B3275C06D822FC9341A2151642C81988', '2010-02-11', 'test object 4!', '2021-05-25 19:36:38'),
('user5', 'e', 'ee', '*5A6AB0B9E84ED1EEC9E8AE9C926922C5D1EDF908', '2013-08-10', 'test object 5!', '2021-05-25 19:36:38'),
('user6', 'f', 'ff', '*2C8BCF8625930454A2B4A1D946A910DF85B0012C', '2011-10-18', 'test object 6!', '2021-05-25 19:36:38'),
('user7', 'g', 'gg', '*AEE0104711CE8D00C4FE9F2690B16A825E433750', '2021-07-21', 'test object 7!', '2021-05-25 19:36:38'),
('user8', 'h', 'hh', '*54DFC5E151FA45166A2350AE664B31A5AD7E8D58', '2018-09-29', 'test object 8!', '2021-05-25 19:36:38'),
('user9', 'i', 'ii', '*9AA36F388A2AD821EFDB3969227F9D51CA157360', '2014-08-05', 'test object 9!', '2021-05-25 19:36:38'),
('username20', '20', '2020', '*9755A98F5E51444AB8358A17F438BAA46251A869', '2001-10-20', 'com eng ', '2021-07-14 13:35:17');

--
-- Triggers `users`
--
DELIMITER $$
CREATE TRIGGER `after_user_insert` AFTER INSERT ON `users` FOR EACH ROW insert INTO new_users 
    VALUES (new.username,new.registeration_date)
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `blocks`
--
ALTER TABLE `blocks`
  ADD PRIMARY KEY (`BLOCKER_USERNAME`,`BLOCKEE_USERNAME`),
  ADD KEY `BLOCKEE_USERNAME` (`BLOCKEE_USERNAME`);

--
-- Indexes for table `follows`
--
ALTER TABLE `follows`
  ADD PRIMARY KEY (`FOLLOWER_USERNAME`,`FOLLOWED_USERNAME`),
  ADD KEY `FOLLOWED_USERNAME` (`FOLLOWED_USERNAME`);

--
-- Indexes for table `hashtag`
--
ALTER TABLE `hashtag`
  ADD PRIMARY KEY (`LABEL`);

--
-- Indexes for table `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`TWEET_ID`,`USERNAME`),
  ADD KEY `USERNAME` (`USERNAME`);

--
-- Indexes for table `login_log`
--
ALTER TABLE `login_log`
  ADD PRIMARY KEY (`USERNAME`,`LOGIN_TIME`);

--
-- Indexes for table `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `SENDER_USERNAME` (`SENDER_USERNAME`),
  ADD KEY `RECEIVER_USERNAME` (`RECEIVER_USERNAME`),
  ADD KEY `TWEET_ID` (`TWEET_ID`);

--
-- Indexes for table `new_tweets`
--
ALTER TABLE `new_tweets`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `new_users`
--
ALTER TABLE `new_users`
  ADD PRIMARY KEY (`NewUsername`);

--
-- Indexes for table `tweet`
--
ALTER TABLE `tweet`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `SENDER_USERNAME` (`SENDER_USERNAME`),
  ADD KEY `PARENT_TWEET_ID` (`PARENT_TWEET_ID`);

--
-- Indexes for table `tweet_hashtag`
--
ALTER TABLE `tweet_hashtag`
  ADD PRIMARY KEY (`TWEET_ID`,`LABEL`),
  ADD KEY `LABEL` (`LABEL`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`USERNAME`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `ID` int(6) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tweet`
--
ALTER TABLE `tweet`
  MODIFY `ID` int(6) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `blocks`
--
ALTER TABLE `blocks`
  ADD CONSTRAINT `blocks_ibfk_1` FOREIGN KEY (`BLOCKER_USERNAME`) REFERENCES `users` (`USERNAME`),
  ADD CONSTRAINT `blocks_ibfk_2` FOREIGN KEY (`BLOCKEE_USERNAME`) REFERENCES `users` (`USERNAME`);

--
-- Constraints for table `follows`
--
ALTER TABLE `follows`
  ADD CONSTRAINT `follows_ibfk_1` FOREIGN KEY (`FOLLOWER_USERNAME`) REFERENCES `users` (`USERNAME`),
  ADD CONSTRAINT `follows_ibfk_2` FOREIGN KEY (`FOLLOWED_USERNAME`) REFERENCES `users` (`USERNAME`);

--
-- Constraints for table `likes`
--
ALTER TABLE `likes`
  ADD CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`TWEET_ID`) REFERENCES `tweet` (`ID`),
  ADD CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`USERNAME`) REFERENCES `users` (`USERNAME`);

--
-- Constraints for table `login_log`
--
ALTER TABLE `login_log`
  ADD CONSTRAINT `login_log_ibfk_1` FOREIGN KEY (`USERNAME`) REFERENCES `users` (`USERNAME`);

--
-- Constraints for table `message`
--
ALTER TABLE `message`
  ADD CONSTRAINT `message_ibfk_1` FOREIGN KEY (`SENDER_USERNAME`) REFERENCES `users` (`USERNAME`),
  ADD CONSTRAINT `message_ibfk_2` FOREIGN KEY (`RECEIVER_USERNAME`) REFERENCES `users` (`USERNAME`),
  ADD CONSTRAINT `message_ibfk_3` FOREIGN KEY (`TWEET_ID`) REFERENCES `tweet` (`ID`);

--
-- Constraints for table `tweet`
--
ALTER TABLE `tweet`
  ADD CONSTRAINT `tweet_ibfk_1` FOREIGN KEY (`SENDER_USERNAME`) REFERENCES `users` (`USERNAME`),
  ADD CONSTRAINT `tweet_ibfk_2` FOREIGN KEY (`PARENT_TWEET_ID`) REFERENCES `tweet` (`ID`);

--
-- Constraints for table `tweet_hashtag`
--
ALTER TABLE `tweet_hashtag`
  ADD CONSTRAINT `tweet_hashtag_ibfk_1` FOREIGN KEY (`TWEET_ID`) REFERENCES `tweet` (`ID`),
  ADD CONSTRAINT `tweet_hashtag_ibfk_2` FOREIGN KEY (`LABEL`) REFERENCES `hashtag` (`LABEL`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
