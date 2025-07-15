					-- Create database for agricultural analysis
CREATE DATABASE CropAnalysis;

USE CropAnalysis;

------------------------------------------------------------------
					-- Create table matching CSV structure
CREATE TABLE CropProduction (
    CropName VARCHAR(50),
    [2000] INT,
    [2001] INT,
    [2002] INT,
    [2003] INT,
    [2004] INT,
    [2005] INT,
    [2006] INT,
    [2007] INT,
    [2008] INT,
    [2009] INT,
    [2010] INT,
    [2011] INT,
    [2012] INT
);

					--Importing the data from the CSV file into SQL
------------------------------------------------------------------
BULK INSERT CropProduction
FROM 'C:\Users\BORASA\Downloads\Crop Production metric tonnes MOFA 2013.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
					--DATA CLEANING
------------------------------------------------------------------
					-- Standardize crop name spellings
UPDATE CropProduction
SET CropName = 'Cocoyam'
WHERE CropName = 'Cocoyam ';

					-- Fix groundnut naming
UPDATE CropProduction
SET CropName = 'Groundnuts'
WHERE CropName = 'Groundnuts,';

					-- Correct paddy rice entry
UPDATE CropProduction
SET CropName = 'Paddy Rice'
WHERE CropName = 'Paddy Rice ';

					-- Handle missing values (set to NULL where zeros appear)
UPDATE CropProduction 
SET [2007] = NULL 
WHERE CropName = 'Sorghum' AND [2007] = 0;

					--DATA ANALYSIS
------------------------------------------------------------------
/* 
Crop Production Analysis (Ghana MOFA 2013 Dataset)
This analysis explores trends in Ghana's agricultural sector using MOFA data.
We'll discover which crops dominated, which struggled, and how production changed.
*/

---------
					-- What were Ghana's top crops in 2012?
---------
SELECT TOP 5 CropName, [2012] AS Production
FROM CropProduction
ORDER BY [2012] DESC;
/* 
INSIGHT: 
By 2012, cassava dominated Ghana's agriculture with 14.5 million tonnes - 
more than the next 3 crops combined! Yam and plantain completed the top 3,
showing the importance of staple starches in Ghanaian diets.
*/

---------
					-- Which crops showed strongest growth since 2000?
---------
SELECT 
    CropName,
    [2000],
    [2012],
    [2012] - [2000] AS ProductionChange,
    ROUND(([2012] - [2000]) * 100.0 / [2000], 1) AS GrowthPercent
FROM CropProduction
ORDER BY GrowthPercent DESC;
/*
INSIGHT:
Yam production exploded with 97% growth since 2000 - a true success story!
Plantain (84% growth) and cassava (79% growth) also showed impressive gains.
But cocoyam tells a different story - production dropped 22% over the same period.
*/

---------
					-- Why was 2007 difficult for many crops?
---------
SELECT 
    CropName,
    [2006],
    [2007],
    [2008],
    [2007] - [2006] AS DeclineFromPrevious,
    ROUND(([2007] - [2006]) * 100.0 / [2006], 1) AS DeclinePercent
FROM CropProduction
WHERE [2007] < [2006]
ORDER BY DeclinePercent;
/*
INSIGHT:
2007 was a crisis year - sorghum production crashed by 51%! 
Groundnuts (-42%), paddy rice (-26%), and millet (-32%) also suffered.
Historical records show this coincided with severe flooding in northern Ghana,
explaining why northern crops like sorghum were hardest hit.
*/

---------
					-- Which crops showed steady growth year after year?
---------
SELECT CropName
FROM CropProduction
WHERE 
    [2012] > [2011] AND
    [2011] > [2010] AND
    [2010] > [2009] AND
    [2009] > [2008];
/* 
INSIGHT:
Cassava was the undisputed consistency champion - growing every single year from 2008-2012.
This reliability made it a food security backbone for Ghanaian families.
*/

---------
					-- Which crops are accelerating their growth?
---------
SELECT 
    CropName,
    [2010],
    [2011],
    [2012],
    [2012] - [2011] AS LastYearGrowth,
    ([2012] - [2011]) - ([2011] - [2010]) AS Acceleration
FROM CropProduction
ORDER BY Acceleration DESC;
/*
INSIGHT:
While yam had the strongest overall growth, cassava showed remarkable acceleration - 
its annual growth increased by 440,000 tonnes from 2011-2012! 
This suggests cassava could become even more dominant in coming years.
*/