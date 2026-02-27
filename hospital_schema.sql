-- ===============================
-- CREATE DATABASE
-- ===============================

DROP DATABASE IF EXISTS HOSPITAL_DB;
CREATE DATABASE HOSPITAL_DB;
USE HOSPITAL_DB;


-- ===============================
-- 2️⃣ DROP TABLES (Child → Parent)
-- ===============================

DROP TABLE IF EXISTS BILLS;
DROP TABLE IF EXISTS LABREPORTS;
DROP TABLE IF EXISTS PRESCRIPTIONS;
DROP TABLE IF EXISTS APPOINTMENTS;
DROP TABLE IF EXISTS DOCTOR_CREDENTIALS;
DROP TABLE IF EXISTS PATIENTS;
DROP TABLE IF EXISTS DOCTORS;
DROP TABLE IF EXISTS DEPARTMENTS;


-- ===============================
-- CREATE TABLES
-- ===============================

CREATE TABLE DEPARTMENTS (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL
);

CREATE TABLE DOCTORS (
    DoctorID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Specialization VARCHAR(100),
    Role VARCHAR(50),
    DepartmentID INT NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES DEPARTMENTS(DepartmentID)
);

CREATE TABLE PATIENTS (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Age INT,
    Gender VARCHAR(1),
    CHECK (LOWER(Gender) IN ('m','f','o'))
);

CREATE TABLE APPOINTMENTS (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentTime DATETIME,
    Status VARCHAR(20),
    CHECK (Status IN ('Scheduled','Completed','Cancelled')),
    FOREIGN KEY (PatientID) REFERENCES PATIENTS(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES DOCTORS(DoctorID)
);

CREATE TABLE PRESCRIPTIONS (
    PrescriptionID INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID INT NOT NULL,
    Medication VARCHAR(200),
    FOREIGN KEY (AppointmentID) REFERENCES APPOINTMENTS(AppointmentID)
);

CREATE TABLE LABREPORTS (
    ReportID INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID INT NOT NULL,
    ReportDetails VARCHAR(200),
    FOREIGN KEY (AppointmentID) REFERENCES APPOINTMENTS(AppointmentID)
);

CREATE TABLE BILLS (
    BillID INT AUTO_INCREMENT PRIMARY KEY,
    AppointmentID INT NOT NULL,
    Amount DECIMAL(10,2),
    BillDate DATE,
    FOREIGN KEY (AppointmentID) REFERENCES APPOINTMENTS(AppointmentID)
);

CREATE TABLE DOCTOR_CREDENTIALS (
    DoctorID INT,
    UserName VARCHAR(100),
    Password VARCHAR(100),
    FOREIGN KEY (DoctorID) REFERENCES DOCTORS(DoctorID)
);




-- ===============================
-- PROCEDURE
-- ===============================

DROP PROCEDURE IF EXISTS GetMonthlyRevenue;

DELIMITER //

CREATE PROCEDURE GetMonthlyRevenue()
BEGIN
    SELECT 
        D1.Name AS DepartmentName,
        MONTH(B.BillDate) AS Month,
        SUM(B.Amount) AS TotalRevenue
    FROM BILLS B
    INNER JOIN APPOINTMENTS A ON A.AppointmentID = B.AppointmentID
    INNER JOIN DOCTORS D ON D.DoctorID = A.DoctorID
    INNER JOIN DEPARTMENTS D1 ON D1.DepartmentID = D.DepartmentID
    GROUP BY D1.Name, MONTH(B.BillDate);
END //

DELIMITER ;


-- ===============================
-- TRIGGER
-- ===============================

DROP TRIGGER IF EXISTS CHECK_NEW_APPOINTMENT;

DELIMITER //

CREATE TRIGGER CHECK_NEW_APPOINTMENT
BEFORE INSERT ON APPOINTMENTS
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM APPOINTMENTS
        WHERE DoctorID = NEW.DoctorID
        AND AppointmentTime = NEW.AppointmentTime
        AND Status = 'Scheduled'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor already has appointment at this time';
    END IF;
END //

DELIMITER ;
USE HOSPITAL_DB;
