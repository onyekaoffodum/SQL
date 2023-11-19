
/*
Bellabeat company case study
The company is Bellabeat is a high-tech company that manufactures health-focused smart products. They collect data on activity, sleep, stress, and reproductive health and this has allowed Bellabeat to empower women with knowledge about their own health and habits
The task is to analyze smart device usage data in order to gain insight into how consumers use non-Bellabeat smart devices

Skills used:Joins, Temp Tables, Windows Functions, Aggregate Functions, filter functions, Creating Views, Converting Data Types

*/

--Below cleaning was done in Excel
--Formatting date column to MM-D-YY format for all files; Format decimal columns to 2 decimal places using the round function for the daily_activity_merged file; 
--I will be used the daily_activity_merged, sleep_day and hourly_calories files as it will enable me answer the business task


-- Loading of daily_activity_merged, sleep_day and hourly_calories files into SQL SSMS

--Viewing the files imported to confirm the data loaded

Select *
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged

Select *
From [SQL Google Data Analytics Bellabeat Project]..hourlyCalories_merged

Select *
From [SQL Google Data Analytics Bellabeat Project]..sleepDay_merged


--After viewing I saw timestamp in the Date column and had to clean to read just Date

Select *, cast(ActivityDate as date) as Cleaned_ActivityDate
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged

Select *, cast(ActivityDate as date) as Cleaned_ActivityDate
From [SQL Google Data Analytics Bellabeat Project]..hourlyCalories_merged

Select *, cast(SleepDay as date) as Cleaned_SleepDay
From [SQL Google Data Analytics Bellabeat Project]..sleepDay_merged


-- Counting distinct users in each file
-- I had to check the sample size for the files chosen to ensure we are considering a good number

Select count(distinct(Id))
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged
--33 users
Select count(distinct(Id))
From [SQL Google Data Analytics Bellabeat Project]..hourlyCalories_merged
--33 users
Select count(distinct(Id))
From [SQL Google Data Analytics Bellabeat Project]..sleepDay_merged
--24 users

--Checking duplicate entries for each file


Select Id, ActivityDate,TotalSteps,TotalDistance,TrackerDistance,LoggedActivitiesDistance,VeryActiveDistance,ModeratelyActiveDistance,LightActiveDistance,SedentaryActiveDistance,VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,SedentaryMinutes,Calories,
cast(ActivityDate as date) as Cleaned_ActivityDate, Count(1)
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged
Group by Id, ActivityDate,TotalSteps,TotalDistance,TrackerDistance,LoggedActivitiesDistance,VeryActiveDistance,ModeratelyActiveDistance,LightActiveDistance,SedentaryActiveDistance,VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,SedentaryMinutes,Calories
Having Count(1) > 1

--No duplicate

Select Id,ActivityDate,ActivityHours,Calories, cast(ActivityDate as date) as Cleaned_ActivityDate, Count (1)
From [SQL Google Data Analytics Bellabeat Project]..hourlyCalories_merged
Group by Id,ActivityDate,ActivityHours,Calories
Having Count(1) > 1

--No duplicate

Select Id,SleepDay,TotalSleepRecords, TotalMinutesAsleep,TotalTimeInBed, cast(SleepDay as date) as Cleaned_SleepDay, Count (1)
From [SQL Google Data Analytics Bellabeat Project]..sleepDay_merged
Group by Id,SleepDay,TotalSleepRecords, TotalMinutesAsleep,TotalTimeInBed
Having Count(1) > 1

--3 duplicate rows

--Dropping duplicate entries for SleepDay_merged by creating another table for it called SleepDay. 
--I had to use the imported sleepday_merged file to drop the duplicate because I couldn't create a new table with the cast sleepday column


Drop Table if exists SleepDay
Create Table SleepDay
(
Id numeric,
SleepDay Datetime,
TotalSleepRecords numeric,
TotalMinutesAsleep numeric,
TotalTimeInBed numeric)

Insert into SleepDay
Select distinct Id, SleepDay, TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed
From [SQL Google Data Analytics Bellabeat Project]..sleepDay_merged

-- Viewing the new table SleepDay

Select *
From SleepDay

-- Confirming duplicates have been removed from the SleepDay file

Select Id,SleepDay,TotalSleepRecords, TotalMinutesAsleep,TotalTimeInBed, Count (1)
From SleepDay
Group by Id,SleepDay,TotalSleepRecords, TotalMinutesAsleep,TotalTimeInBed
Having Count(1) > 1
-- no duplicates again

-- Cleaning the SleepDay column by converting to just date format

Select *, cast(SleepDay as date) as Cleaned_SleepDay
From SleepDay

-- Checking for missing values

Select Id, ActivityDate,TotalSteps,TotalDistance,TrackerDistance,LoggedActivitiesDistance,VeryActiveDistance,ModeratelyActiveDistance,LightActiveDistance,SedentaryActiveDistance,VeryActiveMinutes,FairlyActiveMinutes,LightlyActiveMinutes,SedentaryMinutes,Calories,
cast(ActivityDate as date) as Cleaned_ActivityDate
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged
Where Id is null
-- no missing values

Select Id,ActivityDate,ActivityHours,Calories, cast(ActivityDate as date) as Cleaned_ActivityDate
From [SQL Google Data Analytics Bellabeat Project]..hourlyCalories_merged
Where Id is null
-- no missing values

Select Id,SleepDay,TotalSleepRecords, TotalMinutesAsleep,TotalTimeInBed,cast(SleepDay as date) as Cleaned_SleepDay
From SleepDay
Where Id is null
-- no missing values

-- Joing DailyActivity_merged and SleepDay_merged to enable analyses

SELECT d.Id,d. ActivityDate,d.TotalSteps,d.VeryActiveMinutes,d.FairlyActiveMinutes,d.LightlyActiveMinutes,d.SedentaryMinutes,d.Calories,s.TotalMinutesAsleep
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
SleepDay AS s 
ON d.Id=s.Id
And d.ActivityDate=s.SleepDay


-- Finding the average of TotalSteps, Calories & TotalMinutesAsleep 
-- Referencing the joined files query above and removing the irrelevant columns at this point

SELECT d.Id,
avg(d.TotalSteps) AS AvgTotalSteps,
avg(d.Calories) AS AvgTotalCalories,
avg(s.TotalMinutesAsleep) AS AvgTotalMinutesAsleep
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
SleepDay AS s 
ON d.Id=s.Id
And d.ActivityDate=s.SleepDay
GROUP BY d.Id


--Let's create a temp table for above query for AvgTotalStepsClass so we can explore the table further

Drop Table if exists AvgTotalStepsClass
Create Table AvgTotalStepsClass
(
Id numeric,
AvgTotalSteps float,
AvgTotalCalories float,
AvgTotalMinutesAsleep float)

Insert into AvgTotalStepsClass
SELECT d.Id,
avg(d.TotalSteps) AS AvgTotalSteps,
avg(d.Calories) AS AvgTotalCalories,
avg(s.TotalMinutesAsleep) AS AvgTotalMinutesAsleep
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
SleepDay AS s 
ON d.Id=s.Id
And d.ActivityDate = s.SleepDay
GROUP BY d.Id

--Viewing Table AvgTotalStepsClass

Select *
From AvgTotalStepsClass


--Let's classify users by AvgTotalSteps taken

--Classification has been made per the following article https://www.10000steps.org.au/articles/counting-steps/
--Curled from https://www.kaggle.com/code/macarenalacasa/capstone-case-study-bellabeat

--Sedentary - Less than 5000 steps a day.
--Lightly active - Between 5000 and 7499 steps a day.
--Fairly active - Between 7500 and 9999 steps a day.
--Very active - More than 10000 steps a day.


Select Id, AvgTotalSteps, AvgTotalCalories, AvgTotalMinutesAsleep,
Case 
When AvgTotalSteps < 5000 then 'Sedentary User'
When AvgTotalSteps between 5000 and 7499 then 'Lighlty Active User'
When AvgTotalSteps between 7500 and 9999 then 'Fairly Active User'
When AvgTotalSteps >= 10000 then 'Very Active User'
End UserType
From AvgTotalStepsClass
Group by Id, AvgTotalSteps, AvgTotalCalories, AvgTotalMinutesAsleep


-- Creating Table2-AvgTotalStepsClass2
-- Creating Tables made it easier for me to avoid much complicated queries so as to make queries understandable
-- This table will enable me check for the number of user types

Drop Table if exists AvgTotalStepsClass2
Create Table AvgTotalStepsClass2
(
Id numeric,
AvgTotalSteps float,
AvgTotalCalories float,
AvgTotalMinutesAsleep float,
UserType varchar(max))

Insert into AvgTotalStepsClass2
Select Id, AvgTotalSteps, AvgTotalCalories, AvgTotalMinutesAsleep,
Case 
When AvgTotalSteps < 5000 then 'Sedentary User'
When AvgTotalSteps between 5000 and 7499 then 'Lighlty Active User'
When AvgTotalSteps between 7500 and 9999 then 'Fairly Active User'
When AvgTotalSteps >= 10000 then 'Very Active User'
End UserType
From AvgTotalStepsClass
Group by Id, AvgTotalSteps, AvgTotalCalories, AvgTotalMinutesAsleep

-- Viewing Table2-AvgTotalStepsClass2

Select *
From AvgTotalStepsClass2

-- Checking for number of UserTypes

Select UserType, Count (UserType) as TotalUserType
From AvgTotalStepsClass2
Group By UserType


-- Creating Table3-AvgTotalStepsClass3
-- This will help in calculating the percentage of user types

Drop Table if exists AvgTotalStepsClass3
Create Table AvgTotalStepsClass3
(
UserType varchar(max),
TotalUserType numeric)

Insert into AvgTotalStepsClass3
Select UserType, Count (UserType) as TotalUserType
From AvgTotalStepsClass2
Group By UserType

-- Viewing Table3-AvgTotalStepsClass3

Select *
From AvgTotalStepsClass3


-- Calculating percentage of UserTypes

SELECT UserType, TotalUserType, (TotalUserType / (SELECT SUM(TotalUserType) FROM AvgTotalStepsClass3)) * 100 AS Percent_UserType
FROM AvgTotalStepsClass3
--piechart showing percentage of usertypes


-- Knowing the days of the week users are more active and times when they sleep more
--Referencing the joined table, removing all irrelevant columns at this point and cleaning the date to include days of the week

SELECT
cast(d.ActivityDate as date) as Cleaned_ActivityDate, datename(weekday, cast (d.ActivityDate as date)) as CleanedDay,
d.TotalSteps, d.Calories,s.TotalMinutesAsleep
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
SleepDay AS s 
ON d.Id=s.Id
And d.ActivityDate=s.SleepDay
GROUP BY d.ActivityDate,TotalSteps,Calories,TotalMinutesAsleep

--Let's create a temp table for above query for AvgTotalStepsClass_Date so we can explore the table further by grouping by the new column CleanedDay 

Drop Table if exists AvgTotalStepsClass_Date
Create Table AvgTotalStepsClass_Date
(
Cleaned_ActivityDate Date,
CleanedDay varchar(max),
TotalSteps float,
TotalCalories float,
TotalMinutesAsleep float)

Insert into AvgTotalStepsClass_Date
SELECT
cast(d.ActivityDate as date) as Cleaned_ActivityDate, datename(weekday, cast (d.ActivityDate as date)) as CleanedDay,
d.TotalSteps, d.Calories,s.TotalMinutesAsleep
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
SleepDay AS s 
ON d.Id=s.Id
And d.ActivityDate=s.SleepDay


-- Viewing the new table AvgTotalStepsClass_Date

Select *
From AvgTotalStepsClass_Date

Select CleanedDay,Avg (TotalSteps) as AvgTotalSteps,Avg (TotalMinutesAsleep) as AvgTotalMinutesAsleep 
From AvgTotalStepsClassxx
Group By CleanedDay
Order By CleanedDay
--Barchart showing AvgTotalSteps vs CleanedDay and AvgTotalMinutesAsleep vs CleanedDay

-- Knowing what hour of the day users burn the most calories
-- At this point, calories burnt should depend on the steps taken by users

Select *
From [SQL Google Data Analytics Bellabeat Project]..hourlyCalories_merged

Select ActivityHours, Avg(calories) as Avg_Calories
From [SQL Google Data Analytics Bellabeat Project]..hourlyCalories_merged
Group by ActivityHours
Order by ActivityHours
--Barchart showing calories burnt hourly

-- Correlations
-- We will check for correlation between the TotalStep and TotalMinutesAsleep & TotalSteps and Calories burnt
-- Reference the joined query and removing irrelevant columns at this point

SELECT d.Id,d. ActivityDate,d.TotalSteps,d.Calories,s.TotalMinutesAsleep
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
SleepDay AS s 
ON d.Id=s.Id
And d.ActivityDate=s.SleepDay
-- Scatter Plot of TotalSteps vs Calories and Scatter Plot of TotalSteps vs TotalMinutesAsleep


-- Checking how often users use their device
-- Classifying users into three categories knowing that the date interval is 31 days
-- Classification from https://www.kaggle.com/code/macarenalacasa/capstone-case-study-bellabeat

-- high use - users who use their device between 21 and 31 days.
-- moderate use - users who use their device between 10 and 20 days.
-- low use - users who use their device between 1 and 10 days.


SELECT d.Id,count(d.Id) as Days_Used,
Case
When count(d.ActivityDate) between 1 and 10 then 'low use'
When count(d.ActivityDate) between 11 and 20 then 'moderate use'
When count(d.ActivityDate) between 21 and 31 then 'high use'
End Usage
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
SleepDay AS s 
ON d.Id=s.Id
And d.ActivityDate=s.SleepDay
Group by d.Id


-- Calculation of percentage Usage
-- Creating a temp table to enable this calculation
-- First enabling calculation for total count by user category

Drop Table if exists PercentUsage
Create Table PercentUsage
(
Id numeric,
Days_Used numeric,
Usage varchar(max))

Insert into PercentUsage
SELECT d.Id,count(d.Id) as Days_Used,
Case
When count(d.ActivityDate) between 1 and 10 then 'low use'
When count(d.ActivityDate) between 11 and 20 then 'moderate use'
When count(d.ActivityDate) between 21 and 31 then 'high use'
End Usage
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
SleepDay AS s 
ON d.Id=s.Id
And d.ActivityDate=s.SleepDay
Group by d.Id

-- Viewing the Table-PercentUsage created

Select *
From PercentUsage

-- Calculating the PercentUsage
-- Using this process, I noticed that the percentage values was not rounded up, unlike that where you would create a temp table before calculating the percentage. It is important to note that the Temp table process show decimal values for the percent values

Select Usage, Count (Days_Used) as Usage_Count,Count(Days_Used) * 100/Sum (Count(Days_Used))  over () as Percent_Usage
From PercentUsage
Group By Usage


-- Alternate process for calculating the Percent_Usage
-- Here is a breakdown of the temp table creation mentioned for calculating percent
-- Then, creating a temp table for calculating the percent_usage

Drop Table if exists PercentUsage2
Create Table PercentUsage2
(
Usage varchar(max),
Usage_Count numeric)

Insert into PercentUsage2
Select Usage, Count (Days_Used) as Usage_Count
From PercentUsage
Group By Usage

-- Viewing the Table PercentUsage2 created

Select *
From PercentUsage2


-- Therefore calculating the PercentUsage
-- This process brought out the decimal values for the PercentUsage calculation
 
Select Usage,Usage_Count, (Usage_Count/ (Select Sum(Usage_Count) From PercentUsage2)) * 100 as PercentUsage
From PercentUsage2
Group by Usage,Usage_Count
--piechart showing percentusage

--Knowing the total minutes users use their device in a day
-- Joing the DailyActivity_merged and PercentUsage Table


Select d.Id, d.ActivityDate,d.TotalSteps,d.TotalDistance,d.TrackerDistance,d.LoggedActivitiesDistance,d.VeryActiveDistance,d.ModeratelyActiveDistance,d.LightActiveDistance,d.SedentaryActiveDistance,d.VeryActiveMinutes,d.FairlyActiveMinutes,d.LightlyActiveMinutes,d.SedentaryMinutes,d.Calories,
cast(d.ActivityDate as date) as Cleaned_ActivityDate, p.Days_Used, p.Usage
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
PercentUsage AS p 
ON d.Id=p.Id


-- Calculating total minutes worn by users and the percentage
--  Categorizing users by how long they wore their device in a day
-- All day - device was worn all day. 
-- More than half day - device was worn more than half of the day.
-- Less than half day - device was worn less than half of the day.


Select d.Id, d.ActivityDate,d.TotalSteps,d.TotalDistance,d.TrackerDistance,d.LoggedActivitiesDistance,d.VeryActiveDistance,d.ModeratelyActiveDistance,d.LightActiveDistance,d.SedentaryActiveDistance,d.VeryActiveMinutes,d.FairlyActiveMinutes,d.LightlyActiveMinutes,d.SedentaryMinutes,d.Calories,
cast(d.ActivityDate as date) as Cleaned_ActivityDate,Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes) as Total_Minutes,
Convert(int,round(((Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes))/(1440) * 100), 0)) as Percent_Minutes_Worn,
p.Days_Used, p.Usage,
Case
When Convert(int,round(((Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes))/(1440) * 100), 0)) = 100 then 'All Day'
When Convert(int,round(((Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes))/(1440) * 100), 0)) <100 and Convert(int,round(((Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes))/(1440) * 100), 0)) >=50  then 'More than Half Day'
When Convert(int,round(((Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes))/(1440) * 100), 0)) <50  then 'Less than Half Day'
Else null
End Worn
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
PercentUsage AS p 
ON d.Id=p.Id
Group by d.Id, d.ActivityDate,d.TotalSteps,d.TotalDistance,d.TrackerDistance,d.LoggedActivitiesDistance,d.VeryActiveDistance,d.ModeratelyActiveDistance,d.LightActiveDistance,d.SedentaryActiveDistance,d.VeryActiveMinutes,d.FairlyActiveMinutes,d.LightlyActiveMinutes,d.SedentaryMinutes,d.Calories,p.Days_Used, p.Usage


-- Creating a temp table to better break down table for visualization

Drop Table if exists Worn
Create Table Worn
(
Id numeric,
ActivityDate Date,
TotalSteps numeric,
TotalDistance float,
TrackerDistance float,
LoggedActivitiesDistance float,
VeryActiveDistance float,
ModeratelyActiveDistance float,
LightActiveDistance float,
SedentaryActiveDistance float,
VeryActiveMinutes numeric,
FairlyActiveMinutes numeric,
LightlyActiveMinutes numeric,
SedentaryMinutes numeric,
Calories numeric,
Cleaned_ActivityDate Date,
Total_Minutes numeric,
Percent_Minutes_Worn float,
Days_Used numeric,
Usage varchar (max),
Worn varchar (max))

Insert into Worn
Select d.Id, d.ActivityDate,d.TotalSteps,d.TotalDistance,d.TrackerDistance,d.LoggedActivitiesDistance,d.VeryActiveDistance,d.ModeratelyActiveDistance,d.LightActiveDistance,d.SedentaryActiveDistance,d.VeryActiveMinutes,d.FairlyActiveMinutes,d.LightlyActiveMinutes,d.SedentaryMinutes,d.Calories,
cast(d.ActivityDate as date) as Cleaned_ActivityDate,Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes) as Total_Minutes,
Convert(int,round(((Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes))/(1440) * 100), 0)) as Percent_Minutes_Worn,
p.Days_Used, p.Usage,
Case
When Convert(int,round(((Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes))/(1440) * 100), 0)) = 100 then 'All Day'
When Convert(int,round(((Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes))/(1440) * 100), 0)) <100 and Convert(int,round(((Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes))/(1440) * 100), 0)) >=50  then 'More than Half Day'
When Convert(int,round(((Sum(d.VeryActiveMinutes+d.FairlyActiveMinutes+d.LightlyActiveMinutes+d.SedentaryMinutes))/(1440) * 100), 0)) <50  then 'Less than Half Day'
Else null
End Worn
From [SQL Google Data Analytics Bellabeat Project]..dailyActivity_merged AS d
INNER JOIN 
PercentUsage AS p 
ON d.Id=p.Id
Group by d.Id, d.ActivityDate,d.TotalSteps,d.TotalDistance,d.TrackerDistance,d.LoggedActivitiesDistance,d.VeryActiveDistance,d.ModeratelyActiveDistance,d.LightActiveDistance,d.SedentaryActiveDistance,d.VeryActiveMinutes,d.FairlyActiveMinutes,d.LightlyActiveMinutes,d.SedentaryMinutes,d.Calories,p.Days_Used, p.Usage

Select *
From Worn

-- Visualization purpose
-- Categorzing how often users wore their device

Select Worn, Count(Percent_Minutes_Worn) as Count_Percent_Minutes_Worn, Count(Percent_Minutes_Worn) * 100/Sum (Count(Percent_Minutes_Worn))  over () as Percent_Worn
From Worn
Group by Worn
-- Piechart showing percent_worn in general

-- Visualizing the percentage worn for high use-users

Select Worn, Count(Percent_Minutes_Worn) as Count_Percent_Minutes_Worn, Count(Percent_Minutes_Worn) * 100/Sum (Count(Percent_Minutes_Worn))  over () as Percent_Worn
From Worn
Group by Worn,Usage
Having Usage ='High use'

-- Visualizing the percentage worn for moderate use- users

Select Worn, Count(Percent_Minutes_Worn) as Count_Percent_Minutes_Worn, Count(Percent_Minutes_Worn) * 100/Sum (Count(Percent_Minutes_Worn))  over () as Percent_Worn
From Worn
Group by Worn,Usage
Having Usage ='moderate use'

-- Visualizing the percentage worn for low Use-users

Select Worn, Count(Percent_Minutes_Worn) as Count_Percent_Minutes_Worn, Count(Percent_Minutes_Worn) * 100/Sum (Count(Percent_Minutes_Worn))  over () as Percent_Worn
From Worn
Group by Worn,Usage
Having Usage ='low use'
