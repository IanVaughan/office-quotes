require 'sinatra'
require 'haml'
require 'data_mapper'

DataMapper.setup(:default, 'postgres://postgres:postgres@127.0.0.1/quotes_board')

set :haml, :format => :html5

use Rack::Auth::Basic, "Protected Area" do |username, password|
  username == 'foo' && password == 'bar'
end

get '/' do
  haml :index
end

get '/quotes' do
  haml :quote_index
end

get '/quotes/edit' do
  @quote = Quote.new
  haml :quote_edit
end

get '/quotes/edit/:id' do
  @quote = Quote.get(params[:id])

  @comments = Comment.all(:quote => @quote.id.to_i, :order => [ :id ])

  haml :quote_edit
end

post '/quotes/edit' do
  @quote = params[:id].nil? ? Quote.new : Quote.get(params[:id])
  @quote.person = params[:person]
  @quote.comment = params[:comment]
  @quote.quote_date = params[:quote_date]
  @quote.posted_by = params[:posted_by]

  if @quote.save
    redirect '/quotes'
  else
    haml :quote_edit
  end
end

post '/quotes/:id/comments' do
  @comment = Comment.new
  @comment.quote = params[:id]
  @comment.person = params[:person]
  @comment.comment = params[:comment]
  @comment.save
  
  redirect "quotes/edit/#{params[:id]}"
end

get '/persons' do
  haml :person_index
end

get '/persons/edit' do
  @person = Person.new
  haml :person_edit
end

get '/persons/edit/:id' do
  @person = Person.get(params[:id])
  haml :person_edit
end

post '/persons/edit' do
  @person = params[:id].nil? ? Person.new : Person.get(params[:id])
  @person.name = params[:name]
  @person.avatar = params[:avatar]

  if @person.save
    redirect '/persons'
  else
    haml :person_edit
  end
end

post '/persons/delete/:id' do
  Person.get(params[:id]).destroy

  redirect '/persons'  
end

class Quote
  include DataMapper::Resource

  property :id,         Serial
  property :person,     Integer
  property :comment,    Text
  property :quote_date, DateTime
  property :posted_by,  String
end

class Comment
  include DataMapper::Resource

  property :id,         Serial
  property :quote,      Integer
  property :person,     Integer
  property :comment,    Text
end

class Person
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String
  property :avatar,     String,     :length => 255
end

# DataMapper.auto_migrate!
DataMapper.auto_upgrade!

helpers do
  def render_quote(quote)
    comments = Comment.all(:quote => quote.id, :order => [ :id ])

    html = render_comment(quote)
    comments.each do |comment|
      html += "<div class='comment'>#{render_comment(comment)}</div>"
    end
    html
  end

  def render_comment(quote)
    person = Person.get(quote.person)
    "<img src='#{person.avatar}' /><span class='name'>#{person.name}</span><span class='text'>#{quote.comment}</span>"
  end
end

__END__


@@ layout
%html
  :css
    * {
      padding: 3px;
    }

    body {
      font-family: 'lucida grande', tahoma, verdana, arial, sans-serif;
      font-size: 10pt;
      width: 400px;
      margin: 0 auto;
    }

    img {
      vertical-align:text-top;
    }

    .quote_info {
      color: #ccc;
      border-bottom: 1px solid #eee;
      margin-bottom: 25px;
      text-align: center;
    }

    .quote_info span {
      position: relative;
      top: 11px;
      background-color: white;
    }

    .quote img {
      width: 50px;
      height: 50px;    
    }

    .name {
      color: #3B5998;
      font-weight: bold;
      letter-spacing: 1px;
    }

    .comment {      
      margin: 2px 0px 2px 60px;
      background-color: E4E8F0;
    }

    .comment img{
      width: 30px;
      height: 30px;
    }

  %a{:href=>'/quotes'} Quotes
  %a{:href=>'/persons'} People

  = yield



@@ index
%div.title Hello world.



@@ person_edit
%div.title Person Edit
= @person.errors.inspect unless @person.errors.nil?

- if !@person.id.nil?
  %form{:action => "/persons/delete/#{@person.id}", :method => "post"}  
    %input{:type => "submit", :value => "Delete", :class => "button"}

%form{:action => "/persons/edit", :method => "post"}
  %fieldset
    %ol
      %li
        %label{:for => "name"} Name:
        %input{:type => "text", :name => "name", :class => "text", :value => @person.name}
      %li
        %label{:for => "avatar"} Avatar URL:
        %input{:type => "text", :name => "avatar", :class => "text", :value => @person.avatar}
    %input{:type => "submit", :value => "Submit", :class => "button"}    


@@ person_index
%div.title Person Index
%a{:href => 'persons/edit'} Add
%ol
  - Person.all.each do |person|
    %li
      %img{:src => person.avatar}
      %a{:href => "persons/edit/#{person.id}"}=person.name



@@ quote_index
%div.title Quote Index
%a{:href => 'quotes/edit'} Add
- Quote.all.each do |quote|
  .quote
    .quote_info
      %span
        Posted by 
        =Person.get(quote.posted_by).name
      %span=quote.quote_date.strftime(fmt='%d-%m-%Y')
      %a{:href => "quotes/edit/#{quote.id}"}Edit
    = render_quote(quote)    
    


@@ quote_edit
%div.title Quote Edit
= @quote.errors.inspect unless @quote.errors.nil?

%form{ :action => "/quotes/edit", :method => "post"}
  %fieldset
    %ol
      %li
        %label{:for => "quote_date"} Date:
        %input{:type => "text", :name => "quote_date", :class => "text", :value => @quote.quote_date}
      %li
        %label{:for => "posted_by"} Posted By:
        %select{:name =>  "posted_by"}
          - for person in Person.all
            %option{:selected => @quote.posted_by, :value => person.id} #{person.name}

  %fieldset
    %ol
      %li
        %label{:for => "person"} Name:
        %select{:name =>  "person"}
          - for person in Person.all
            %option{:selected => @quote.person, :value => person.id} #{person.name}
      %li
        %label{:for => "comment"} Comment:
        %textarea{:name => "comment", :text => @quote.comment}

    %input{:type => "submit", :value => "Add", :class => "property"}

= render_comment(@quote)
=@comments.inspect

- if !@comments.nil?
  - @comments.each do |comment|
    = render_comment(comment)

%form{ :action => "/quotes/#{@quote.id}/comments", :method => "post"}
  %fieldset    
    %ol
      %li
        %label{:for => "person"} Name:
        %select{:name =>  "person"}
          - for person in Person.all
            %option{:selected => @quote.person, :value => person.id} #{person.name}
      %li
        %label{:for => "comment"} Comment:
        %textarea{:name => "comment", :value => @quote.comment}

    %input{:type => "submit", :value => "Add", :class => "property"}