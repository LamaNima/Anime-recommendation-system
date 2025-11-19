/*
	SECTION 1 - Analytics Queries
*/
-- Anime with rating > 8.0
SELECT anime_id, name, rating
FROM Anime
WHERE rating > 8.0
ORDER BY rating DESC;

-- Anime by single genre
SELECT a.name, g.genre_name
FROM Anime a
JOIN Anime_Genres ag ON a.anime_id = ag.anime_id
JOIN Genres g ON ag.genre_id = g.genre_id
WHERE g.genre_name = 'action';

-- Anime by multiple genre
SELECT a.name
FROM Anime a
JOIN Anime_Genres ag ON a.anime_id = ag.anime_id
JOIN Genres g ON ag.genre_id = g.genre_id
WHERE g.genre_name IN ('action','romance','thriller')
GROUP BY a.anime_id,a.name
HAVING COUNT(DISTINCT g.genre_name) = 3;

-- Anime with more than 2 genres
SELECT a.name, COUNT(ag.genre_id) as genre_count
FROM Anime a
JOIN Anime_Genres ag ON a.anime_id = ag.anime_id
GROUP BY a.name
HAVING COUNT(ag.genre_id) > 2;

-- Average user rating by genre
SELECT g.genre_name, ROUND(CAST(AVG(r.rating * 1.0) AS FLOAT),2) AS avg_rating
FROM User_Ratings r
JOIN Anime a ON r.anime_id = a.anime_id
JOIN Anime_Genres ag ON a.anime_id = ag.anime_id
JOIN Genres g ON ag.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY avg_rating DESC;

-- Most popular anime by number of ratings
SELECT a.name, COUNT(r.rating) AS rating_count
FROM User_Ratings r
JOIN Anime a ON r.anime_id = a.anime_id
GROUP BY a.name
ORDER BY rating_count DESC;

-- Top 3 animes for each genre
WITH ranked_cte AS(
	SELECT 
		a.name,
		g.genre_name,
		a.rating,
		RANK() OVER (PARTITION BY g.genre_name ORDER BY a.rating DESC) as rnk
	FROM 
		Anime a 
	JOIN 
		Anime_Genres ag ON ag.anime_id = a.anime_id
	JOIN 
		Genres g ON ag.genre_id = g.genre_id
)
SELECT * 
FROM ranked_cte
WHERE rnk <=3;

-- Most active users
SELECT user_id, COUNT(*) AS ratings_count
FROM User_Ratings
GROUP BY user_id
ORDER BY ratings_count DESC;

--Anime similar to a given anime based on shared genres
SELECT
    a2.anime_id,
    a2.name,
    COUNT(*) AS shared_genres
FROM Anime_Genres ag1
JOIN Anime_Genres ag2 ON ag1.genre_id = ag2.genre_id
JOIN Anime a2 ON ag2.anime_id = a2.anime_id
WHERE ag1.anime_id = 1
  AND ag2.anime_id <> 1
GROUP BY a2.anime_id, a2.name
ORDER BY shared_genres DESC;


/*
	SECTION 2- Views
*/
-- Anime with all genres aggregated
CREATE OR ALTER VIEW vw_anime_with_genres AS
SELECT
    a.anime_id,
    a.name,
    STRING_AGG(g.genre_name, ', ') AS genres,
    a.rating
FROM Anime a
JOIN Anime_Genres ag ON a.anime_id = ag.anime_id
JOIN Genres g ON ag.genre_id = g.genre_id
GROUP BY a.anime_id, a.name, a.rating;

-- View: Anime popularity ranking
CREATE OR ALTER VIEW vw_anime_popularity AS
SELECT
    a.anime_id,
    a.name,
    COUNT(r.rating) AS total_ratings,
    AVG(r.rating) AS avg_rating
FROM Anime a
LEFT JOIN User_Ratings r ON a.anime_id = r.anime_id
GROUP BY a.anime_id, a.name;

-- View: User rating statistics
CREATE OR ALTER VIEW vw_user_rating_summary AS
SELECT
    user_id,
    COUNT(*) AS total_ratings,
    AVG(rating) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM User_Ratings
GROUP BY user_id;


/*
	SECTION 3- Stored Procedures
*/
-- Get anime above a minimum rating
CREATE OR ALTER PROCEDURE sp_get_top_anime
    @min_rating FLOAT
AS
BEGIN
    SELECT anime_id, title, rating
    FROM Anime
    WHERE rating >= @min_rating
    ORDER BY rating DESC;
END;

-- Get anime belonging to a specific genre
CREATE OR ALTER PROCEDURE sp_get_anime_by_genre
    @genre_name NVARCHAR(100)
AS
BEGIN
    SELECT a.anime_id, a.name, a.rating
    FROM Anime a
    JOIN Anime_Genres ag ON a.anime_id = ag.anime_id
    JOIN Genres g ON ag.genre_id = g.genre_id
    WHERE g.genre_name = @genre_name
    ORDER BY a.rating DESC;
END;

-- Get genre statistics
CREATE OR ALTER PROCEDURE sp_get_genre_statistics
AS
BEGIN
    SELECT
        g.genre_name,
        COUNT(ag.anime_id) AS total_anime,
        ROUND((AVG(a.rating)),2) AS avg_rating,
        MIN(a.rating) AS min_rating,
        MAX(a.rating) AS max_rating
    FROM Genres g
    JOIN Anime_Genres ag ON g.genre_id = ag.genre_id
    JOIN Anime a ON ag.anime_id = a.anime_id
    GROUP BY g.genre_name
    ORDER BY avg_rating DESC;
END;

