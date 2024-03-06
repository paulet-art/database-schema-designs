-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS Bookstore;
USE Bookstore;

-- Drop tables if they exist
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;
DROP TABLE IF EXISTS Publishers;
DROP TABLE IF EXISTS Categories;

-- Create Authors table
CREATE TABLE Authors (
    AuthorID INT AUTO_INCREMENT PRIMARY KEY,
    AuthorName VARCHAR(100) NOT NULL
);

-- Create Publishers table
CREATE TABLE Publishers (
    PublisherID INT AUTO_INCREMENT PRIMARY KEY,
    PublisherName VARCHAR(100) NOT NULL
);

-- Create Categories table
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

-- Create Books table
CREATE TABLE Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    AuthorID INT,
    PublisherID INT,
    CategoryID INT,
    ISBN VARCHAR(13) UNIQUE,
    PublishYear YEAR,
    Price DECIMAL(10, 2),
    StockQuantity INT,
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID),
    FOREIGN KEY (PublisherID) REFERENCES Publishers(PublisherID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Error handling for foreign key constraints
DELIMITER $$
CREATE TRIGGER trg_books_authorid
BEFORE INSERT ON Books
FOR EACH ROW
BEGIN
    DECLARE author_count INT;
    SELECT COUNT(*) INTO author_count FROM Authors WHERE AuthorID = NEW.AuthorID;
    IF author_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid AuthorID. Author does not exist.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_books_publisherid
BEFORE INSERT ON Books
FOR EACH ROW
BEGIN
    DECLARE publisher_count INT;
    SELECT COUNT(*) INTO publisher_count FROM Publishers WHERE PublisherID = NEW.PublisherID;
    IF publisher_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid PublisherID. Publisher does not exist.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_books_categoryid
BEFORE INSERT ON Books
FOR EACH ROW
BEGIN
    DECLARE category_count INT;
    SELECT COUNT(*) INTO category_count FROM Categories WHERE CategoryID = NEW.CategoryID;
    IF category_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid CategoryID. Category does not exist.';
    END IF;
END$$
DELIMITER ;

