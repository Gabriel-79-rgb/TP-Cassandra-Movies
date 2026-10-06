USE movies;

INSERT INTO movies (imdb_id, title, year, runtime, genres, directors, countries, imdb_rating, imdb_votes)
VALUES ('tt0000001', 'Film Test', 2024, '100 min', ['Drama'], ['Jean Test'], ['France'], 7.5, 1000);

SELECT * FROM movies WHERE imdb_id = 'tt0000001';

UPDATE movies SET imdb_rating = 8.0 WHERE imdb_id = 'tt0000001';
SELECT imdb_id, title, imdb_rating FROM movies WHERE imdb_id = 'tt0000001';

DELETE FROM movies WHERE imdb_id = 'tt0000001';
SELECT * FROM movies WHERE imdb_id = 'tt0000001';
