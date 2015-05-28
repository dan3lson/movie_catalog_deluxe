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

get "/" do
  erb :index, locals: {}
end

get "/movies" do
  movies = sql("SELECT * FROM movies ORDER BY title LIMIT 25")
  erb :"/movies/index", locals: { movies: movies }
end

get "/movies/:movie" do
  movie = params[:movie]
  erb :"/movies/show", locals: { movie: movie }
end

get "/actors" do
  actors = sql("SELECT * FROM actors ORDER BY name DESC LIMIT 25")
  erb :"/actors/index", locals: { actors: actors }
end

get "/actors/:actor" do
  actor = params[:actor]
  erb :"/actors/show", locals: { actor: actor }
end
