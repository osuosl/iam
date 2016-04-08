require File.expand_path("../environment", __FILE__)

# Ruby
require 'rubygems'
require 'bundler'

Bundler.require

$: << File.expand_path('../', __FILE__)

# Sinatra
require 'sinatra/base'

# Iam
require 'models'
Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each {|file| require file }


class Iam < Sinatra::Base

  ##
  # static Pages
  ##

  get '/' do
    "Hello"
  end

  ##
  # Clients
  ##

  get '/clients' do
    clients = DB[:clients].to_a
    erb :"clients/index", locals: { clients: clients }
  end

  get '/clients/new' do
    erb :"clients/new"
  end

  post '/clients' do
    date_of_birth = params[:person][:date_of_birth]
    DB[:clients].insert(
      first_name: params[:person][:first_name],
      last_name: params[:person][:last_name],
      date_of_birth: date_of_birth.empty? ? nil : date_of_birth,
    )
    redirect '/clients'
  end

  get '/clients/:id' do
    person = DB[:clients].where(id: params[:id]).first
    erb :"clients/show", locals: { person: person }
  end

  get '/clients/:id/edit' do
    person = DB[:clients].where(id: params[:id]).first
    erb :"clients/edit", locals: { person: person }
  end

  put '/clients/:id' do
    date_of_birth = params[:person][:date_of_birth]
    DB[:clients].where(id: params[:id]).update(
      first_name: params[:person][:first_name],
      last_name: params[:person][:last_name],
      date_of_birth: date_of_birth.empty? ? nil : date_of_birth,
    )
    redirect "/clients/#{params[:id]}"
  end

  delete '/clients/:id' do
    DB[:clients].where(id: params[:id]).delete
    redirect "/clients"
  end
end
