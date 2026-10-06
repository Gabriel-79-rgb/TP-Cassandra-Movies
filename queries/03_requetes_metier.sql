USE movies;

-- REQ-01 : films d'un réalisateur (du plus récent au plus ancien)
SELECT title, year, imdb_rating
FROM movies_by_director
WHERE director = 'Ron Howard';

-- REQ-02 : top 5 des films d'un genre, triés par note
SELECT title, imdb_rating, year
FROM movies_by_genre
WHERE genre = 'Drama'
LIMIT 5;

-- REQ-03 : films d'une année, triés par note
SELECT title, imdb_rating
FROM movies_by_year
WHERE year = 2014;

-- REQ-04 : nombre de films par pays (le classement se fait en Python)
SELECT country, nb_movies
FROM movie_count_by_country;

-- REQ-05 : films de plus de 3 genres
SELECT title, genres
FROM movies_by_genre_count
WHERE genre_count IN (4, 5, 6, 7);
