require "sinatra"
require "pg"
require "pry"

get "/" do
  erb :index, locals: {}
end

get "/movies" do
  erb :"/movies/index", locals: {}
end

get "/movies/:movie" do
  erb :"/movies/show", locals: {}
end

get "/actors" do
  erb :"/actors/index", locals: {}
end

get "/actors/:actor" do
  erb :"/actors/show", locals: {}
end
