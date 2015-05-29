require "sinatra"
require "pg"
require "pry"

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

def sql(statement)
  all = db_connection do |conn|
    conn.exec(statement)
  end
  all = all.to_a
end

def actor_info(actor_id)
  sql("
    SELECT
      actors.name,
      movies.id,
      movies.title,
      cast_members.character
    FROM cast_members
    JOIN movies ON cast_members.movie_id = movies.id
    JOIN actors ON cast_members.actor_id = actors.id
    WHERE actors.id = '#{actor_id}'
  ")
end

def movies_info
# why doesn't it work if studio and genre are swapped?
  sql("
    SELECT
      movies.id,
      movies.title,
      movies.year,
      movies.rating,
      studios.name AS studio,
      genres.name AS genre
    FROM movies
    JOIN genres ON movies.genre_id = genres.id
    JOIN studios ON movies.studio_id = studios.id
    ORDER BY title
  ")
end

def movie_actors(movie_id)
  sql("
    SELECT actors.name AS actor, actors.id, cast_members.character
    FROM cast_members
    JOIN actors ON actors.id = cast_members.actor_id
    JOIN movies ON cast_members.movie_id = movies.id
    WHERE movies.id = '#{movie_id}'
  ")
end

get "/" do
  erb :index, locals: {}
end

get "/movies" do
  erb :"/movies/index", locals: { movies: movies_info }
end

get "/movies/:movie" do
  movie_id = params[:movie]
  movies_details = sql("
    SELECT
      movies.id,
      movies.title,
      movies.year,
      movies.rating,
      studios.name AS studio,
      genres.name AS genre
    FROM movies
    JOIN genres ON movies.genre_id = genres.id
    JOIN studios ON movies.studio_id = studios.id
    WHERE movies.id = '#{movie_id}'
    ORDER BY title
  ")
  erb :"/movies/show", locals: {
    movies_details: movies_details,
    movies_cast: movie_actors(movie_id)
  }
end

get "/actors" do
  actors = sql("
    SELECT *
    FROM actors
    ORDER BY name
  ")
  erb :"/actors/index", locals: { actors: actors }
end

get "/actors/:id" do
  actor_id = params[:id]
  performances = actor_info(actor_id)

  erb :"/actors/show", locals: {
    actor_id: actor_id,
    performances: performances
  }
end
