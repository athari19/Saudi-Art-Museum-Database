-- ============================================================
-- Saudi Art Museum Database
-- Umm Al-Qura University — Database Course Project
-- ============================================================

CREATE DATABASE Saudi_Art_museum;
USE Saudi_Art_museum;

-- ============================================================
-- TABLE CREATION
-- ============================================================

-- Staff Table
CREATE TABLE staff (
    staffID    INT PRIMARY KEY,
    fullname   VARCHAR(100),
    profession VARCHAR(25)
);

INSERT INTO staff (staffID, fullname, profession)
VALUES (1, 'Ali Ahmad', 'curator'),
       (2, 'Omar Adam', 'receptionist'),
       (3, 'Sara Sami', 'guide'),
       (4, 'Amal saad', 'curator'),
       (5, 'noor anas', 'guide');

ALTER TABLE staff
MODIFY COLUMN profession VARCHAR(25) NOT NULL;

ALTER TABLE staff
ADD UNIQUE (fullname);

-- Visitor Table
CREATE TABLE Visitor (
    VisitorID INT PRIMARY KEY,
    FullName  VARCHAR(100) NOT NULL,
    Gender    VARCHAR(10)  NULL,
    VisitDate DATE NOT NULL
);

INSERT INTO Visitor (VisitorID, FullName, Gender, VisitDate)
VALUES (201, 'Ali Hassan', 'M', '2025-01-10'),
       (202, 'Sara Yousef', 'F', '2025-01-12'),
       (203, 'Omar Saleh', 'M', '2025-01-15'),
       (204, 'Lama Fahad', NULL, '2025-01-20'),
       (205, 'Hadi Khaled', 'M', '2025-01-25');

-- Ticket Table
CREATE TABLE Ticket (
    Tnum     VARCHAR(10) PRIMARY KEY,
    IssDate  DATE NOT NULL,
    Price    DECIMAL(5,2) NOT NULL,
    payMeth  CHAR(50) NULL,
    VisitorID INT,
    staffID   INT,
    FOREIGN KEY (staffID) REFERENCES staff (staffID),
    FOREIGN KEY (VisitorID) REFERENCES Visitor (VisitorID)
);

INSERT INTO Ticket (Tnum, IssDate, Price, payMeth, VisitorID, staffID)
VALUES ('81', '2025-01-10', 75.50, 'Cash', 201, 1),
       ('72', '2025-01-12', 55.50, 'Card', 202, 1),
       ('307', '2025-01-15', 75.50, 'Cash', 203, 4),
       ('14', '2025-01-20', 75.50, NULL, 204, 5),
       ('55', '2025-01-25', 55.50, 'Card', 205, 5);

-- Artists Table
CREATE TABLE Artists (
    ArtistID     INT PRIMARY KEY,
    FirstName    VARCHAR(80) NOT NULL,
    LastName     VARCHAR(80) NOT NULL,
    Nationality  VARCHAR(80) NOT NULL,
    Profession   VARCHAR(30) NOT NULL,
    Email        VARCHAR(120) UNIQUE,
    ShortBio     VARCHAR(255) NULL,
    CHECK (Profession IN ('Painter', 'Photographer', 'Sculptor'))
);

INSERT INTO Artists (ArtistID, FirstName, LastName, Nationality, Profession, Email, ShortBio)
VALUES (1, 'Pablo', 'Picasso', 'Spanish', 'Painter', 'picasso@example.com', '20th century influential painter.'),
       (2, 'Frida', 'Kahlo', 'Mexican', 'Painter', 'frida@example.com', NULL),
       (3, 'Annie', 'Leibovitz', 'American', 'Photographer', 'annie@example.com', 'Known for iconic celebrity portraits.'),
       (4, 'Henry', 'Moore', 'British', 'Sculptor', 'henry@example.com', 'Famous for abstract bronze sculptures.'),
       (5, 'Steve', 'McCurry', 'American', 'Photographer', 'steve@example.com', 'Captured the Afghan Girl photograph.');

-- Art Piece Table
CREATE TABLE Art_Piece (
    ArtID           INT PRIMARY KEY,
    ArtName         VARCHAR(20) NOT NULL,
    Category        VARCHAR(15) NOT NULL,
    Year_Produced   INT NOT NULL,
    Art_Description VARCHAR(200) NOT NULL,
    Produce_Artist  VARCHAR(20) NOT NULL,
    ArtistID        INT,
    FOREIGN KEY (ArtistID) REFERENCES Artists(ArtistID)
);

INSERT INTO Art_Piece (ArtID, ArtName, Category, Year_Produced, Art_Description, Produce_Artist, ArtistID)
VALUES (501, 'The Persistence of Memory', 'Painting', 1931, 'Iconic surrealist work by Pablo Picasso', 'Pablo Picasso', 1),
       (502, 'The Great Wave off Kanagawa', 'Print', 1831, 'Famous woodblock print by Frida Kahlo', 'Frida Kahlo', 2),
       (503, 'A Sunday Afternoon', 'Painting', 1886, 'Large pointillist painting by Annie Leibovitz', 'Annie Leibovitz', 3),
       (504, 'Bird in Space', 'Sculpture', 1923, 'Abstract bronze sculpture by Henry Moore.', 'Henry Moore', 4),
       (505, 'The Scream', 'Painting', 1893, 'Expressionist painting by Steve McCurry.', 'Steve McCurry', 5);

-- Manages Table (Staff <-> Art Piece)
CREATE TABLE Manages (
    staffID INT NOT NULL,
    ArtID   INT NOT NULL,
    PRIMARY KEY (staffID, ArtID),
    FOREIGN KEY (staffID) REFERENCES staff(staffID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (ArtID) REFERENCES Art_Piece(ArtID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO Manages (staffID, ArtID)
VALUES (1, 501), (1, 502), (4, 503), (4, 504), (2, 505), (3, 501), (5, 503);

-- Assist Table (Staff <-> Visitor)
CREATE TABLE Assist (
    staffID   INT NOT NULL,
    VisitorID INT NOT NULL,
    PRIMARY KEY (staffID, VisitorID),
    FOREIGN KEY (staffID) REFERENCES staff(staffID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (VisitorID) REFERENCES visitor(VisitorID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO Assist (staffID, VisitorID)
VALUES (1, '201'), (2, '202'), (3, '203'), (4, '204'), (5, '205');

-- ============================================================
-- QUERIES
-- ============================================================

-- Select: male visitors
SELECT FullName, Gender, VisitDate
FROM Visitor
WHERE Gender = 'M';

-- Aggregate: total sales per staff member
SELECT staffID, SUM(Price) AS TotalSales
FROM Ticket
GROUP BY staffID;

-- Aggregate: number of art pieces managed per staff member
SELECT staffID, COUNT(ArtID) AS NumberOfManagedArtPieces
FROM Manages
GROUP BY staffID;

-- Join: visitor + ticket details
SELECT Visitor.FullName, Ticket.Tnum, Ticket.Price, Ticket.payMeth
FROM Visitor
INNER JOIN Ticket
ON Visitor.VisitorID = Ticket.VisitorID;

-- Subquery: top-paying visitors
SELECT FullName
FROM Visitor
WHERE VisitorID IN (
    SELECT VisitorID FROM Ticket
    WHERE Price = (SELECT MAX(Price) FROM Ticket)
);

-- View: full ticket details
CREATE VIEW Ticket_Details AS
SELECT Ticket.Tnum, Ticket.IssDate, Ticket.Price, Ticket.payMeth,
       Visitor.FullName AS Visitor_FullName,
       Staff.FullName AS Staff_FullName
FROM Ticket, Visitor, Staff
WHERE Ticket.VisitorID = Visitor.VisitorID
  AND Ticket.staffID = Staff.staffID;

SELECT * FROM Ticket_Details;
