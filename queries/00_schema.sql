CREATE KEYSPACE IF NOT EXISTS movies
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE movies;

CREATE TABLE IF NOT EXISTS movies (
    imdb_id text PRIMARY KEY,
    title text,
    year int,
    runtime text,
    genres list<text>,
    directors list<text>,
    countries list<text>,
    imdb_rating double,
    imdb_votes int
);

CREATE TABLE IF NOT EXISTS movies_by_director (
    director text,
    year int,
    imdb_id text,
    title text,
    imdb_rating double,
    PRIMARY KEY ((director), year, imdb_id)
) WITH CLUSTERING ORDER BY (year DESC, imdb_id ASC);

CREATE TABLE IF NOT EXISTS movies_by_genre (
    genre text,
    imdb_rating double,
    imdb_id text,
    title text,
    year int,
    PRIMARY KEY ((genre), imdb_rating, imdb_id)
) WITH CLUSTERING ORDER BY (imdb_rating DESC, imdb_id ASC);

CREATE TABLE IF NOT EXISTS movies_by_year (
    year int,
    imdb_rating double,
    imdb_id text,
    title text,
    PRIMARY KEY ((year), imdb_rating, imdb_id)
) WITH CLUSTERING ORDER BY (imdb_rating DESC, imdb_id ASC);

CREATE TABLE IF NOT EXISTS movie_count_by_country (
    country text PRIMARY KEY,
    nb_movies counter
);

CREATE TABLE IF NOT EXISTS movies_by_genre_count (
    genre_count int,
    imdb_id text,
    title text,
    genres list<text>,
    PRIMARY KEY ((genre_count), imdb_id)
);
