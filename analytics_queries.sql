USE HOSPITAL_DB;

-- =====================================
-- DATASET OVERVIEW
-- =====================================

-- Total records
SELECT COUNT(*) AS TotalPatients FROM PATIENTS;
SELECT COUNT(*) AS TotalDoctors FROM DOCTORS;
SELECT COUNT(*) AS TotalAppointments FROM APPOINTMENTS;
SELECT COUNT(*) AS TotalBills FROM BILLS;

-- Unique patients & total appointments
SELECT 
    COUNT(DISTINCT PatientID) AS UniquePatients,
    COUNT(*) AS TotalAppointments
FROM APPOINTMENTS;


-- =====================================
-- REVENUE METRICS
-- =====================================

-- Total Revenue
SELECT 
    CONCAT('₹ ', FORMAT(SUM(Amount), 0)) AS TotalRevenue
FROM BILLS;

-- Average Bill Value
SELECT 
    ROUND(AVG(Amount), 2) AS AvgBillValue
FROM BILLS;

-- Monthly Revenue Trend
SELECT 
    MONTH(BillDate) AS Month,
    SUM(Amount) AS TotalRevenue
FROM BILLS
GROUP BY MONTH(BillDate)
ORDER BY Month;

-- Month-over-Month Growth (MySQL 8+)
SELECT 
    Month,
    TotalRevenue,
    TotalRevenue - LAG(TotalRevenue) 
        OVER (ORDER BY Month) AS MoM_Growth
FROM (
    SELECT 
        MONTH(BillDate) AS Month,
        SUM(Amount) AS TotalRevenue
    FROM BILLS
    GROUP BY MONTH(BillDate)
) t;


-- =====================================
--  DEPARTMENT ANALYSIS
-- =====================================

-- Revenue share by department
SELECT 
    D1.Name AS Department,
    SUM(B.Amount) AS Revenue,
    ROUND(
        SUM(B.Amount) * 100.0 /
        (SELECT SUM(Amount) FROM BILLS), 2
    ) AS RevenueSharePercent
FROM BILLS B
JOIN APPOINTMENTS A ON A.AppointmentID = B.AppointmentID
JOIN DOCTORS D ON D.DoctorID = A.DoctorID
JOIN DEPARTMENTS D1 ON D1.DepartmentID = D.DepartmentID
GROUP BY D1.Name
ORDER BY Revenue DESC;


-- =====================================
-- DOCTOR PERFORMANCE
-- =====================================

-- Top 5 revenue generating doctors
SELECT 
    D.Name,
    SUM(B.Amount) AS DoctorRevenue
FROM BILLS B
JOIN APPOINTMENTS A ON A.AppointmentID = B.AppointmentID
JOIN DOCTORS D ON D.DoctorID = A.DoctorID
GROUP BY D.Name
ORDER BY DoctorRevenue DESC
LIMIT 5;

-- Top doctor only
SELECT 
    D.Name,
    SUM(B.Amount) AS DoctorRevenue
FROM BILLS B
JOIN APPOINTMENTS A ON A.AppointmentID = B.AppointmentID
JOIN DOCTORS D ON D.DoctorID = A.DoctorID
GROUP BY D.Name
ORDER BY DoctorRevenue DESC
LIMIT 1;


-- =====================================
-- OPERATIONAL EFFICIENCY
-- =====================================

-- Overall cancellation rate
SELECT 
    ROUND(
        SUM(CASE WHEN Status='Cancelled' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2
    ) AS CancellationRatePercent
FROM APPOINTMENTS;

-- Completed appointments count
SELECT 
    COUNT(*) AS CompletedAppointments
FROM APPOINTMENTS
WHERE Status = 'Completed';