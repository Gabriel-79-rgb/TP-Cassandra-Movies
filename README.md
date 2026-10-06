# TP Cassandra : Films OMDb

## Sujet

Exploiter des données de films avec Apache Cassandra : modélisation
orientée requêtes, import depuis une API, requêtes CQL métier.

## API

[OMDb API](https://www.omdbapi.com/), avec une clé gratuite (1000 requêtes
par jour). Recherche par mot-clé (`s=`), puis détail par `imdbID` (`i=`).

## Données

100 films récupérés avec les mots-clés `batman`, `star`, `love`, `war`, `night`.

Principaux champs : `imdbID`, `Title`, `Year`, `Runtime`, `Genre`, `Director`,
`Country`, `imdbRating`, `imdbVotes`.

## Modèle Cassandra

Six tables, dont une par besoin métier (voir
[documentation/modelisation.md](documentation/modelisation.md)) :

`movies`, `movies_by_director`, `movies_by_genre`, `movies_by_year`,
`movie_count_by_country`, `movies_by_genre_count`.

## Requêtes métier

| REQ | Besoin | Table |
|---|---|---|
| 01 | Films d'un réalisateur | `movies_by_director` |
| 02 | Top des films d'un genre | `movies_by_genre` |
| 03 | Films d'une année | `movies_by_year` |
| 04 | Nombre de films par pays | `movie_count_by_country` |
| 05 | Films de plus de 3 genres | `movies_by_genre_count` |

## Lancer le projet

```bash
docker compose up -d
docker exec -i cassandra cqlsh < queries/00_schema.sql

python -m venv venv
source venv/Scripts/activate      # Linux/macOS : venv/bin/activate
pip install -r requirements.txt

cp .env.example .env              # puis renseigner OMDB_API_KEY
python script/getapi.py
```

## Structure

```text
README.md
docker-compose.yml
requirements.txt
.env.example
script/getapi.py
queries/        00_schema, 01_verification, 02_crud, 03_requetes_metier
documentation/  modelisation.md
captures/       captures d'écran des résultats
```

## Captures

Voir le dossier `captures/`.