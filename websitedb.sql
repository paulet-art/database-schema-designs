-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS WebsiteDB;
USE WebsiteDB;

-- Drop tables if they exist
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Posts;
DROP TABLE IF EXISTS Comments;
DROP TABLE IF EXISTS Categories;

-- Create Users table
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(100) NOT NULL UNIQUE,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL
);

-- Create Posts table
CREATE TABLE Posts (
    PostID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT,
    Title VARCHAR(255) NOT NULL,
    Content TEXT NOT NULL,
    CategoryID INT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create Comments table
CREATE TABLE Comments (
    CommentID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT,
    PostID INT,
    Content TEXT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (PostID) REFERENCES Posts(PostID)
);

-- Create Categories table
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

-- Error handling for foreign key constraints
DELIMITER $$
CREATE TRIGGER trg_posts_userid
BEFORE INSERT ON Posts
FOR EACH ROW
BEGIN
    DECLARE user_count INT;
    SELECT COUNT(*) INTO user_count FROM Users WHERE UserID = NEW.UserID;
    IF user_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid UserID. User does not exist.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_posts_categoryid
BEFORE INSERT ON Posts
FOR EACH ROW
BEGIN
    DECLARE category_count INT;
    SELECT COUNT(*) INTO category_count FROM Categories WHERE CategoryID = NEW.CategoryID;
    IF category_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid CategoryID. Category does not exist.';
    END IF;
END$$
DELIMITER ;

-- Stored procedure to add a new user
DELIMITER $$
CREATE PROCEDURE AddUser(
    IN p_Username VARCHAR(100),
    IN p_Email VARCHAR(255),
    IN p_Password VARCHAR(255)
)
BEGIN
    DECLARE duplicate_count INT;
    SELECT COUNT(*) INTO duplicate_count FROM Users WHERE Username = p_Username OR Email = p_Email;
    IF duplicate_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username or email already exists.';
    ELSE
        INSERT INTO Users (Username, Email, Password) VALUES (p_Username, p_Email, p_Password);
    END IF;
END$$
DELIMITER ;

-- View to display posts with comments count
CREATE VIEW PostsWithCommentsCount AS
SELECT 
    p.PostID, 
    p.Title, 
    p.Content, 
    p.CreatedAt,
    c.CategoryName,
    u.Username AS Author,
    COUNT(co.CommentID) AS CommentsCount
FROM Posts p
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN Users u ON p.UserID = u.UserID
LEFT JOIN Comments co ON p.PostID = co.PostID
GROUP BY p.PostID;

