use football

-- union with between the tables
SELECT * FROM dbo.pl20_21
UNION ALL 
SELECT * FROM dbo.pl19_20
UNION ALL
SELECT * FROM dbo.pl18_19
UNION ALL 
SELECT * FROM dbo.pl17_18
UNION ALL 
SELECT * FROM dbo.pl16_17
UNION ALL 
SELECT * FROM dbo.pl15_16

--Create temp table about Goalkeeper
DROP TABLE if exists #Goalkeeper
CREATE TABLE #Goalkeeper(
Name varchar(50),
Position varchar(50),
Appearances int,
Goals_Conceded int,
Errors_leading_to_goal int,
Saves int,
Penalties_Saved int)
INSERT INTO #GoalKeeper
SELECT name, position, appearances, goals_conceded, errors_leading_to_goal, saves, penalties_saved
FROM (SELECT * FROM dbo.pl20_21
UNION ALL 
SELECT * FROM dbo.pl19_20
UNION ALL
SELECT * FROM dbo.pl18_19
UNION ALL 
SELECT * FROM dbo.pl17_18
UNION ALL 
SELECT * FROM dbo.pl16_17
UNION ALL 
SELECT * FROM dbo.pl15_16) AS total
WHERE position = 'Goalkeeper'

SELECT * FROM #Goalkeeper

SELECT NAME,COUNT(APPEARANCES)
FROM #Goalkeeper
GROUP BY NAME

SELECT GK.name, PL.club, SUM(GK.APPEARANCES) AS total_appearances, SUM(GK.goals_conceded) AS total_goals_conceded,
SUM(GK.Errors_leading_to_goal) AS total_errors_leading_to_goals, SUM(GK.Saves) AS total_saves,SUM(GK.Penalties_saved) AS total_penalties_saved,
CONVERT(NUMERIC(5,3),(CAST(SUM(GK.goals_conceded) AS float))/(CAST(SUM(GK.appearances) AS float))) AS percentage__of_goals_conceded,
CONVERT(NUMERIC(5,3),(CAST(SUM(GK.saves) AS float))/(CAST(SUM(GK.appearances) AS float))) AS percentage_of_saves
FROM #Goalkeeper AS GK
INNER JOIN dbo.Players AS PL
ON gk.name = PL.name
GROUP BY GK.name, PL.club
HAVING SUM(GK.Appearances) > 50
ORDER BY SUM(GK.Appearances)DESC, percentage__of_goals_conceded DESC;

-- Goalkeepers CTE
WITH Goalkeeper AS
(SELECT GK.name, PL.club, SUM(GK.APPEARANCES) AS total_appearances, SUM(GK.goals_conceded) AS total_goals_conceded,
SUM(GK.Errors_leading_to_goal) AS total_errors_leading_to_goals, SUM(GK.Saves) AS total_saves,SUM(GK.Penalties_saved) AS total_penalties_saved,
CONVERT(NUMERIC(5,3),(CAST(SUM(GK.goals_conceded) AS float))/(CAST(SUM(GK.appearances) AS float))) AS percentage_of_goals_conceded,
CONVERT(NUMERIC(5,3),(CAST(SUM(GK.saves) AS float))/(CAST(SUM(GK.appearances) AS float))) AS percentage_of_saves
FROM #Goalkeeper AS GK
INNER JOIN dbo.Players AS PL
ON gk.name = PL.name
GROUP BY GK.name, PL.club
HAVING SUM(GK.Appearances) > 50)
SELECT * FROM Goalkeeper
ORDER BY total_appearances DESC, percentage_of_goals_conceded DESC;

--CREATE TEMP TABLE ABOUT DEFENDERS
DROP TABLE if exists #Defender
CREATE TABLE #Defender(
Name varchar(50),
Position varchar(50),
Appearances int,
Tackles int,
Tackle_success_percent float,
Duels_won int,
Duels_lost int,
Successful_50_50 int)
INSERT INTO #Defender
SELECT name, position, appearances, tackles, tackle_success_percent, duels_won, duels_lost, successful_50_50
FROM (SELECT * FROM dbo.pl20_21
UNION ALL 
SELECT * FROM dbo.pl19_20
UNION ALL
SELECT * FROM dbo.pl18_19
UNION ALL 
SELECT * FROM dbo.pl17_18
UNION ALL 
SELECT * FROM dbo.pl16_17
UNION ALL 
SELECT * FROM dbo.pl15_16) AS total
WHERE position = 'Defender';

SELECT * FROM #Defender;
-- Defender CTE
WITH Defender AS
(SELECT DF.name, PL.club, SUM(DF.APPEARANCES) AS total_appearances, SUM(DF.Tackles) as total_tackles, SUM(DF.successful_50_50) as total_successful_50_50,
SUM(DF.duels_won) AS total_duels_won, SUM(DF.duels_lost) AS total_duels_lost,
CASE WHEN (CAST((SUM(DF.duels_won) + SUM(DF.duels_lost)) AS float)) > 0 THEN CONVERT(numeric(5, 3), (CAST(SUM(DF.duels_won) AS float))/(CAST((SUM(DF.duels_won) + SUM(DF.duels_lost)) AS float)))
ELSE 0
END AS percentage_of_duels_won
FROM #Defender AS DF
INNER JOIN dbo.Players AS PL
ON DF.name = PL.name
GROUP BY DF.name, PL.club)
SELECT *, RANK() OVER (PARTITION BY club ORDER BY percentage_of_duels_won DESC, total_appearances DESC) AS rank_defender
FROM Defender; 

--CREATE VIEW ABOUT DEFENDER
CREATE VIEW Defender AS
WITH Defender AS
(SELECT DF.name, PL.club, SUM(DF.APPEARANCES) AS total_appearances, SUM(DF.Tackles) as total_tackles, SUM(DF.successful_50_50) as total_successful_50_50,
SUM(DF.duels_won) AS total_duels_won, SUM(DF.duels_lost) AS total_duels_lost,
CASE WHEN (CAST((SUM(DF.duels_won) + SUM(DF.duels_lost)) AS float)) > 0 THEN CONVERT(numeric(5, 3), (CAST(SUM(DF.duels_won) AS float))/(CAST((SUM(DF.duels_won) + SUM(DF.duels_lost)) AS float)))
ELSE 0
END AS percentage_of_duels_won
FROM (SELECT * FROM dbo.pl20_21
UNION ALL 
SELECT * FROM dbo.pl19_20
UNION ALL
SELECT * FROM dbo.pl18_19
UNION ALL 
SELECT * FROM dbo.pl17_18
UNION ALL 
SELECT * FROM dbo.pl16_17
UNION ALL 
SELECT * FROM dbo.pl15_16 
WHERE position = 'Defender') AS DF
INNER JOIN dbo.Players AS PL
ON DF.name = PL.name
GROUP BY DF.name, PL.club)
SELECT *, RANK() OVER (PARTITION BY club ORDER BY percentage_of_duels_won DESC, total_appearances DESC) AS rank_defender
FROM Defender;