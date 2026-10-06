# Modélisation Cassandra : films OMDb

## Keyspace

```sql
CREATE KEYSPACE movies
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
```

Un seul nœud pour ce TP, donc `replication_factor = 1`.

## Tables

| Table | Clé de partition | Clustering | Rôle |
|---|---|---|---|
| `movies` | `imdb_id` | aucun | Table de référence : détail d'un film |
| `movies_by_director` | `director` | `year DESC, imdb_id` | Films d'un réalisateur |
| `movies_by_genre` | `genre` | `imdb_rating DESC, imdb_id` | Films d'un genre triés par note |
| `movies_by_year` | `year` | `imdb_rating DESC, imdb_id` | Films d'une année triés par note |
| `movie_count_by_country` | `country` | aucun | Compteur de films par pays |
| `movies_by_genre_count` | `genre_count` | `imdb_id` | Films regroupés par nombre de genres |

## Choix de modélisation

- **Une table par requête** : Cassandra interroge efficacement par clé de
  partition. Chaque besoin métier a donc sa table, dont la clé de partition
  est la valeur cherchée dans le `WHERE`.
- **Dénormalisation** : un film est écrit dans plusieurs tables, et une fois
  par genre ou par réalisateur dans `movies_by_genre` et `movies_by_director`.
  On duplique les données pour éviter les jointures, qui n'existent pas en CQL.
- **Clés de clustering** : elles servent au tri (`imdb_rating DESC`,
  `year DESC`) et garantissent l'unicité des lignes grâce à `imdb_id`.
  Sans `imdb_id`, deux films de même note dans un genre s'écraseraient.
- **Compteurs** : `movie_count_by_country` utilise le type `counter`.
  Les compteurs ne sont pas idempotents, donc le script fait un `TRUNCATE`
  avant chaque import. Un `counter` ne peut pas servir à trier : le classement
  des pays se fait en Python (`top_countries()`).
- **Valeurs `N/A`** : `year` et `imdb_rating` sont des clés et ne peuvent pas
  être nuls. Le script ignore les films concernés dans les tables concernées.
- **Normalisation des pays** : `USA` est fusionné avec `United States`
  à l'import.
- **Pas de `ALLOW FILTERING`** : toutes les requêtes passent par la clé de
  partition.

## Besoins métier

### REQ-01

**Besoin métier** : lister les films d'un réalisateur, du plus récent au plus ancien.

**Requête CQL** :
```sql
SELECT title, year, imdb_rating FROM movies_by_director
WHERE director = 'Ron Howard';
```

**Clé de partition utilisée** : `director`

**Justification** : tous les films d'un réalisateur sont dans la même
partition, déjà triés par `year DESC`.

### REQ-02

**Besoin métier** : afficher les 5 meilleurs films d'un genre.

**Requête CQL** :
```sql
SELECT title, imdb_rating, year FROM movies_by_genre
WHERE genre = 'Drama' LIMIT 5;
```

**Clé de partition utilisée** : `genre`

**Justification** : le clustering `imdb_rating DESC` fournit le tri,
et `LIMIT 5` lit seulement le début de la partition.

### REQ-03

**Besoin métier** : lister les films sortis une année donnée, triés par note.

**Requête CQL** :
```sql
SELECT title, imdb_rating FROM movies_by_year WHERE year = 2014;
```

**Clé de partition utilisée** : `year`

**Justification** : une partition par année, triée par `imdb_rating DESC`.

### REQ-04

**Besoin métier** : connaître les pays qui produisent le plus de films.

**Requête CQL** :
```sql
SELECT country, nb_movies FROM movie_count_by_country;
```

**Clé de partition utilisée** : `country`

**Justification** : la table contient un compteur par pays. Cassandra ne
trie pas un résultat agrégé : le classement est fait côté Python.
La table est petite (26 pays), donc la lecture complète reste acceptable.

### REQ-05

**Besoin métier** : trouver les films qui ont plus de 3 genres.

**Requête CQL** :
```sql
SELECT title, genres FROM movies_by_genre_count
WHERE genre_count IN (4, 5, 6, 7);
```

**Clé de partition utilisée** : `genre_count`

**Justification** : une comparaison `> 3` est impossible sur une clé de
partition. On utilise donc `IN` sur les valeurs possibles. C'est acceptable ici
car il y a peu de partitions (7 valeurs différentes). Pour un très grand volume,
on matérialiserait un indicateur booléen `more_than_3_genres`.

## Limites

- Les `count(*)` sans clé de partition génèrent l'avertissement
  `Aggregation query used without partition key`. Ils servent uniquement à
  vérifier un petit jeu de données.
- Le jeu de données (100 films) vient de mots-clés de recherche
  (`batman`, `star`, `love`, `war`, `night`), il n'est donc pas représentatif.