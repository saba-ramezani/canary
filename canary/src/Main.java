import com.sun.org.apache.xpath.internal.operations.Variable;

import javax.xml.stream.events.Comment;
import java.sql.*;
import java.util.Locale;
import java.util.Scanner;

public class Main {

    private static Connection connection;

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/canary?useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=UTC";
            String user = "root";
            String pass = "";
            connection = DriverManager.getConnection(url, user, pass);
            if (connection != null) {
                System.out.println("Connection Successful");
            }
            String input = input = scanner.nextLine();
            while (!input.equals("Finish")) {
                input(input);
                input = scanner.nextLine();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public static void input(String input) {
        String[] splitInput = input.split(" ");
        if (splitInput[0].equals("Login")) {
            String username = splitInput[1];
            String password = splitInput[2];
            login(username,password);
        }
        else if (splitInput[0].equals("Follow")) {
            String followedUsername = splitInput[1];
            follow(followedUsername);
        }
        else if (splitInput[0].equals("Unfollow")) {
            String followedUsername = splitInput[1];
            unfollow(followedUsername);
        }
        else if (splitInput[0].equals("Block")) {
            String blockeeUsername = splitInput[1];
            block(blockeeUsername);
        }
        else if (splitInput[0].equals("Unblock")) {
            String blockeeUsername = splitInput[1];
            unblock(blockeeUsername);
        }
        else if (splitInput[0].equals("Comment")) {
            int parentTweetId = Integer.parseInt(splitInput[splitInput.length-1]);
            String commentContent = "";
            for (int i=1 ; i< splitInput.length-1 ; i++) {
                commentContent = commentContent.concat(splitInput[i] + " ");
            }
            comment(commentContent,parentTweetId);
        }
        else if (splitInput[0].equals("Like") && splitInput[1].equals("Tweet")) {
            int tweetId = Integer.parseInt(splitInput[2]);
            likeTweet(tweetId);
        }
        else if (splitInput[0].equals("New") && splitInput[1].equals("Tweet")) {
            String content = "";
            for (int i=2 ; i< splitInput.length ; i++) {
                content = content.concat(splitInput[i] + " ");
            }
            newTweet(content);
        }
        else if (splitInput[0].equals("Register")) {
            String username = splitInput[1];
            String firstname = splitInput[2];
            String lastname = splitInput[3];
            String hashedPassword = splitInput[4];
            String birthdate = splitInput[5];
            String biography = "";
            for (int i=6 ; i< splitInput.length ; i++) {
                biography = biography.concat(splitInput[i] + " ");
            }
            register(username,firstname,lastname,hashedPassword,birthdate,biography);
        }
        else if (splitInput[0].equals("Send") && splitInput[1].equals("Message")) {
            String receiverUsername = splitInput[3];
            if (splitInput[2].equals("Tweet")) {
                String tweetId = splitInput[4];
                sendMessage(receiverUsername,null,tweetId);
                System.out.println("Done");
            }
            else if (splitInput[2].equals("Text")) {
                String messageText = "";
                for (int i=4; i< splitInput.length ; i++) {
                    messageText = messageText.concat(splitInput[i] + " ");
                }
                sendMessage(receiverUsername,messageText,null);
                System.out.println("Done");
            }
        }
        else if (splitInput[0].equals("Get")) {
            if (splitInput[1].equals("Comments")) {
                int parentTweetId = Integer.parseInt(splitInput[2]);
                getComments(parentTweetId);
            }
            else if (splitInput[1].equals("Followings") && splitInput[2].equals("Activity")) {
                getFollowingsActivity();
            }
            else if (splitInput[1].equals("Likes") && splitInput[2].equals("Count")) {
                int tweetId = Integer.parseInt(splitInput[3]);
                getLikesCount(tweetId);
            }
            else if (splitInput[1].equals("Likes") && splitInput[2].equals("List")) {
                int tweetId = Integer.parseInt(splitInput[3]);
                getLikesList(tweetId);
            }
            else if (splitInput[1].equals("Logins") && splitInput[2].equals("List")) {
                String username = splitInput[3];
                getLoginsList(username);
            }
            else if (splitInput[1].equals("Message") && splitInput[2].equals("Senders") && splitInput[3].equals("List")) {
                getMessageSendersList();
            }
            else if (splitInput[1].equals("Personal") && splitInput[2].equals("Tweets")) {
                getPersonalTweets();
            }
            else if (splitInput[1].equals("Popular") && splitInput[2].equals("Tweets")) {
                getPopularTweets();
            }
            else if (splitInput[1].equals("Tweets") && splitInput[2].equals("Of") && splitInput[3].equals("Hashtag")) {
                String hashtag = splitInput[4];
                getTweetsOfHashtag(hashtag);
            }
            else if (splitInput[1].equals("User") && splitInput[2].equals("Activity")) {
                String targetUsername = splitInput[3];
                getUserActivity(targetUsername);
            }
            else if (splitInput[1].equals("User") && splitInput[2].equals("Messages")) {
                String targetUsername = splitInput[3];
                getUserMessages(targetUsername);
            }
        }
    }


    public static void block(String blockeeUsername) {
        String query = "{ call Block(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("blockeeUsernameIn", blockeeUsername);
            resultSet = statement.executeQuery();
            System.out.println("Done!");
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void unblock(String blockeeUsername) {
        String query = "{ call Unblock(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("blockeeUsernameIn", blockeeUsername);
            resultSet = statement.executeQuery();
            System.out.println("Done!");
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void follow(String followedUsername) {
        String query = "{ call follow(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("followedUsernameIn", followedUsername);
            resultSet = statement.executeQuery();
            System.out.println("Done!");
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void unfollow(String followedUsername) {
        String query = "{ call Unfollow(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("followedUsernameIn", followedUsername);
            resultSet = statement.executeQuery();
            System.out.println("Done!");
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getComments(int parentTweetId) {
        String query = "{ call getComments(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setInt("parentTweetIdIn", parentTweetId);
            resultSet = statement.executeQuery();
            int i = 0;
            while (resultSet.next()) {
                int id = resultSet.getInt("id");
                String content = resultSet.getString("content");
                int parent_tweet_id = resultSet.getInt("parent_tweet_id");
                String sender_username = resultSet.getString("sender_username");
                String send_date = resultSet.getString("send_date");
                System.out.println("ID: " + id + "     " +
                        "Content: " + content + "     " +
                        "Parent_Tweet_Id: " + parent_tweet_id + "     " +
                        "Sender_Username: " + sender_username + "     " +
                        "Send-Date: " + send_date + "\n");
                i++;
            }
            if (i == 0) {
                System.out.println("There is nothing for you here body! :)");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getFollowingsActivity() {
        String query = "{ call GetFollowingsActivity() }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            resultSet = statement.executeQuery();
            int i = 0;
            while (resultSet.next()) {
                int id = resultSet.getInt("id");
                String content = resultSet.getString("content");
                int parent_tweet_id = resultSet.getInt("parent_tweet_id");
                String sender_username = resultSet.getString("sender_username");
                String send_date = resultSet.getString("send_date");
                System.out.println("ID: " + id + "     " +
                        "Content: " + content + "     " +
                        "Parent_Tweet_Id: " + parent_tweet_id + "     " +
                        "Sender_Username: " + sender_username + "     " +
                        "Send-Date: " + send_date + "\n");
                i++;
            }
            if (i == 0) {
                System.out.println("There is nothing for you here body! :)");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getLikesCount(int tweetId) {
        String query = "{ call GetLikesCount(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setInt("tweetIdIn", tweetId);
            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                int likes_count = resultSet.getInt("likes_count");
                System.out.println("Likes_Count: " + likes_count + "\n");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getLikesList(int tweetId) {
        String query = "{ call getLikesList(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setInt("TweetIdIn", tweetId);
            resultSet = statement.executeQuery();
            int i = 0;
            while (resultSet.next()) {
                String username = resultSet.getString("username");
                System.out.println("Username: " + username + "\n");
                i++;
            }
            if (i == 0) {
                System.out.println("There is nothing for you here body! :)");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getLoginsList(String username) {
        String query = "{ call getLoginsList(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("usernameIn", username);
            resultSet = statement.executeQuery();
            int i = 0;
            while (resultSet.next()) {
                String login_time = resultSet.getString("login_time");
                System.out.println("login_time: " + login_time + "\n");
                i++;
            }
            if (i == 0) {
                System.out.println("There is nothing for you here body! :)");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getMessageSendersList() {
        String query = "{ call getMessageSendersList() }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            resultSet = statement.executeQuery();
            int i = 0;
            while (resultSet.next()) {
                String sender_username = resultSet.getString("sender_username");
                System.out.println("Sender_Username: " + sender_username + "\n");
                i++;
            }
            if (i == 0) {
                System.out.println("There is nothing for you here body! :)");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getPersonalTweets() {
        String query = "{ call getPersonalTweets() }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            resultSet = statement.executeQuery();
            int i = 0;
            while (resultSet.next()) {
                int id = resultSet.getInt("id");
                String content = resultSet.getString("content");
                int parent_tweet_id = resultSet.getInt("parent_tweet_id");
                String sender_username = resultSet.getString("sender_username");
                String send_date = resultSet.getString("send_date");
                System.out.println("ID: " + id + "     " +
                        "Content: " + content + "     " +
                        "Parent_Tweet_Id: " + parent_tweet_id + "     " +
                        "Sender_Username: " + sender_username + "     " +
                        "Send-Date: " + send_date + "\n");
                i++;
            }
            if (i == 0) {
                System.out.println("There is nothing for you here body! :)");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getPopularTweets() {
        String query = "{ call getPopularTweets() }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            resultSet = statement.executeQuery();
            int i = 0;
            while (resultSet.next()) {
                int id = resultSet.getInt("id");
                String content = resultSet.getString("content");
                int parent_tweet_id = resultSet.getInt("parent_tweet_id");
                String sender_username = resultSet.getString("sender_username");
                String send_date = resultSet.getString("send_date");
                int likes_count = resultSet.getInt("likes_count");
                System.out.println("ID: " + id + "     " +
                        "Content: " + content + "     " +
                        "Parent_Tweet_Id: " + parent_tweet_id + "     " +
                        "Sender_Username: " + sender_username + "     " +
                        "Send-Date: " + send_date + "     " +
                        "likes_count: " + likes_count + "\n");
                i++;
            }
            if (i == 0) {
                System.out.println("There is nothing for you here body! :)");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getTweetsOfHashtag(String hashtag) {
        String query = "{ call getTweetsOfHashtag(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("hashtagIn", hashtag);
            resultSet = statement.executeQuery();
            int i = 0;
            while (resultSet.next()) {
                int id = resultSet.getInt("id");
                String content = resultSet.getString("content");
                int parent_tweet_id = resultSet.getInt("parent_tweet_id");
                String sender_username = resultSet.getString("sender_username");
                String send_date = resultSet.getString("send_date");
                System.out.println("ID: " + id + "     " +
                        "Content: " + content + "     " +
                        "Parent_Tweet_Id: " + parent_tweet_id + "     " +
                        "Sender_Username: " + sender_username + "     " +
                        "Send-Date: " + send_date + "\n");
                i++;
            }
            if (i == 0) {
                System.out.println("There is nothing for you here body! :)");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getUserActivity(String targetUser) {
        String query = "{ call getUserActivity(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("targetUserIn", targetUser);
            resultSet = statement.executeQuery();
            int i = 0;
            while (resultSet.next()) {
                int id = resultSet.getInt("id");
                String content = resultSet.getString("content");
                int parent_tweet_id = resultSet.getInt("parent_tweet_id");
                String sender_username = resultSet.getString("sender_username");
                String send_date = resultSet.getString("send_date");
                System.out.println("ID: " + id + "     " +
                        "Content: " + content + "     " +
                        "Parent_Tweet_Id: " + parent_tweet_id + "     " +
                        "Sender_Username: " + sender_username + "     " +
                        "Send-Date: " + send_date + "\n");
                i++;
            }
            if (i == 0) {
                System.out.println("There is nothing for you here body! :)");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void getUserMessages(String targetUser) {
        String query = "{ call getUserMessages(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("targetUsernameIn", targetUser);
            resultSet = statement.executeQuery();
            int i = 0;
            while (resultSet.next()) {
                int id = resultSet.getInt("id");
                String sender_username = resultSet.getString("sender_username");
                String receiver_username = resultSet.getString("receiver_username");
                int tweet_id = resultSet.getInt("tweet_id");
                String message_content = resultSet.getString("message_content");
                String time_sent = resultSet.getString("time_sent");
                System.out.println("ID: " + id + "     " +
                        "sender_username: " + sender_username + "     " +
                        "receiver_username: " + receiver_username + "     " +
                        "tweet_id: " + tweet_id + "     " +
                        "message_content: " + message_content + "     " +
                        "time_sent: " + time_sent + "\n");
                i++;
            }
            if (i == 0) {
                System.out.println("There is nothing for you here body! :)");
            }
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void comment(String commentContent, int parentTweetId) {
        String query = "{ call giveComment(? , ?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setInt("parentTweetIdIn" , parentTweetId);
            statement.setString("commentContentIn", commentContent);
            resultSet = statement.executeQuery();
            System.out.println("Done!");
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void likeTweet(int tweetId) {
        String query = "{ call likeTweet(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setInt("tweetIdIn", tweetId);
            resultSet = statement.executeQuery();
            System.out.println("Done!");
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void login(String username, String password) {
        String query = "{ call login(? , ?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("usernameIn" , username);
            statement.setString("passwordIn", password);
            resultSet = statement.executeQuery();
            System.out.println("Done!");
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void newTweet(String content) {
        String query = "{ call newTweet(?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("contentIn", content);
            resultSet = statement.executeQuery();
            System.out.println("Done!");
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void register(String username,
                                String firstname,
                                String lastname,
                                String hashed_password,
                                String birthdate,
                                String biography) {
        String query = "{ call register(?,?,?,?,?,?) }";
        ResultSet resultSet;
        try (CallableStatement statement = connection.prepareCall(query)) {
            statement.setString("UsernameIn" , username);
            statement.setString("FirstNameIn" , firstname);
            statement.setString("LastNameIn" , lastname);
            statement.setString("Hashed_PasswordIn" , hashed_password);
            statement.setString("BirthdateIn", birthdate);
            statement.setString("BiographyIn" , biography);
            resultSet = statement.executeQuery();
            System.out.println("Done!");
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }


    public static void sendMessage(String receiverUsername,
                                   String messageText,
                                   String tweetId) {
        if (tweetId != null) {
            String query = "{ call SendMessage(?,?,?) }";
            ResultSet resultSet;
            try (CallableStatement statement = connection.prepareCall(query)) {
                statement.setNull("messageTextIn", Types.NULL);
                statement.setString("receiverUsernameIn", receiverUsername);
                statement.setInt("tweetIdIn" , Integer.parseInt(tweetId));
                resultSet = statement.executeQuery();
                System.out.println("Done!");
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }
        else {
            String query = "{ call SendMessage(?,?,?) }";
            ResultSet resultSet;
            try (CallableStatement statement = connection.prepareCall(query)) {
                statement.setNull("tweetIdIn",Types.NULL);
                statement.setString("receiverUsernameIn", receiverUsername);
                statement.setString("messageTextIn" , messageText);
                resultSet = statement.executeQuery();
                System.out.println("Done!");
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }
    }



}
