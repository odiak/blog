#!/usr/bin/env ruby
# coding: utf-8

require "bundler"
Bundler.require

require "digest/md5"
require "./setting"

class Post < ActiveRecord::Base
end

configure do
  set :app_file, __FILE__
  set :database, "sqlite3:///db/blog.sqlite3"
  set :haml, format: :html5
  disable :session
  use Rack::Session::Cookie,
    key: "rack.session",
    expire_after: SESSION_EXPIRE_AFTER,
    secret: SESSION_SECRET
  use Rack::Csrf, raise: true
  mime_type :atom, "application/atom+xml"
end

helpers do
  def format_date(t)
    return t.strftime("%Y-%m-%d")
  end

  def format_datetime(t)
    return t.strftime("%Y-%m-%d %H:%M:%S")
  end

  def csrf_tag
    return Rack::Csrf.csrf_tag(env)
  end

  def production?
    return Sinatra::Application.production?
  end

  def last_updated
    return Post.order("updated_at DESC").first.updated_at
  end
end

def authorized?
  return !!session[:authorized]
end

def authorize!
  unless session[:authorized]
    session[:callback] = request.url
    redirect "/authorize"
  end
end

def valid_password?(password)
  return Digest::MD5.hexdigest(password) == PASSWORD_DIGEST
end

get "/" do
  @posts = Post.order(created_at: :desc).all
  haml :posts
end

get "/posts/new" do
  authorize!
  @title = "New Post"
  @action = ""
  @post = Post.new
  haml :post_form
end

post "/posts/new" do
  authorize!
  post = Post.create(title: params[:title], body: params[:body])
  redirect "/posts/#{post.id}"
end

post "/posts/preview" do
  authorize!
  @post = Post.new(
    title: params[:title],
    body: params[:body],
    created_at: DateTime.now
  )
  haml :post
end

get "/posts/:id" do
  @post = Post.find_by_id(params[:id])
  halt 404 unless @post
  @title = @post.title
  @next_post = Post.order("created_at").where("created_at > ?", @post.created_at).first
  @previous_post = Post.order("created_at desc").where("created_at < ?", @post.created_at).first
  haml :post
end

get "/posts/:id/edit" do
  authorize!
  @title = "Edit Post"
  @action = "/posts/#{params[:id]}/update"
  @post = Post.find_by_id(params[:id])
  halt 404 unless @post
  haml :post_form
end

post "/posts/:id/update" do
  authorize!
  @post = Post.find_by_id(params[:id])
  halt 404 unless @post
  @post.title = params[:title]
  @post.body = params[:body]
  @post.save
  redirect "/posts/#{params[:id]}"
end

post "/posts/:id/delete" do
  authorize!
  post = Post.find_by_id(params[:id])
  if post
    post.delete
    redirect "/"
  else
    halt 404
  end
end

get "/authorize" do
  @failed = params[:failed]
  haml :authorize
end

post "/authorize" do
  if valid_password? params[:password]
    session[:authorized] = true
    if session[:callback]
      redirect session[:callback]
    else
      redirect "/"
    end
  else
    redirect "/authorize?failed=1"
  end
end

get "/feed" do
  @posts = Post.order("created_at DESC").limit(100)
  content_type :atom
  haml :feed, layout: false, format: :xhtml
end

not_found do
  haml :not_found
end

error Rack::Csrf::InvalidCsrfToken do
  "CSRF Error!"
end
