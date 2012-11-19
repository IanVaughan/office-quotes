require 'sinatra'
require 'haml'
require 'data_mapper'

DataMapper.setup(:default, 'postgres://postgres:postgres@127.0.0.1/quotes_board')

set :haml, :format => :html5

get '/' do
  haml :index
end

get '/quotes/edit' do
  haml :quote_edit
end

post '/quotes/edit' do
  raise params.inspect
end

get '/authors' do
  haml :author_index
end

get '/authors/edit' do
  @author = Author.new
  haml :author_edit
end

get '/authors/edit/:id' do
  @author = Author.get(params[:id])
  haml :author_edit
end

post '/authors/edit' do
  @author = params[:id].nil? ? Author.new : Author.get(params[:id])
  @author.name = params[:name]
  @author.avatar = params[:avatar]

  if @author.save
    redirect '/authors'
  else
    haml :author_edit
  end
end

class Quote
  include DataMapper::Resource

  property :id,         Serial
  property :author,     Integer
  property :body,       Text
  property :quote_date, DateTime
  property :parent_id,  Integer
  property :posted_by,  String
end

class Author
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String
  property :avatar,     String,     :length => 255
end

# DataMapper.auto_migrate!
DataMapper.auto_upgrade!

__END__

@@ layout
%html
  = yield


@@ index
%div.title Hello world.


@@ author_edit
%div.title Author Edit
= @author.errors.inspect unless @author.errors.nil?
%form{:action => "/authors/edit", :method => "post"}
  %fieldset
    %ol
      %li
        %label{:for => "name"} Name:
        %input{:type => "text", :name => "name", :class => "text", :value => @author.name}
      %li
        %label{:for => "avatar"} Avatar URL:
        %input{:type => "text", :name => "avatar", :class => "text", :value => @author.avatar}
    %input{:type => "submit", :value => "Submit", :class => "button"}


@@ author_index
%div.title Author Index
%a{:href => 'authors/edit'} Add
%ol
  - Author.all.each do |author|
    %li
      %img{:src => author.avatar}
      %a{:href => "authors/edit/#{author.id}"}=author.name



@@ quote_edit
%div.title Quote Edit
%form{ :action => "", :method => "post"}
  %fieldset
    %ol
      %li
        %label{:for => "name"} Name:
        %input{:type => "text", :name => "name", :class => "text"}
      %li
        %label{:for => "mail"} email:
        %input{:type => "text", :name => "mail", :class => "text"}
      %li
        %label{:for => "body"} Message:
        %textarea{:name => "body"}
    %input{:type => "submit", :value => "Send", :class => "property"}



  button :id,         Serial
  property :author,     Integer
  property :body,       Text
  property :quote_date, DateTime
  property :parent_id,  Integer
  property :posted_by,  String