require 'sinatra'
require 'haml'
require 'data_mapper'

DataMapper.setup(:default, 'postgres://postgres:postgres@127.0.0.1/quotes_board')

set :haml, :format => :html5

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

post '/quotes/edit' do
  @quote = params[:id].nil? ? Quote.new : Quote.get(params[:id])
  @quote.author = params[:author]
  @quote.body = params[:body]
  @quote.quote_date = params[:quote_date]
  @quote.posted_by = params[:posted_by] if params[:parent_id].nil?
  @quote.parent_id = params[:parent_id] unless params[:parent_id].nil?

  if @quote.save
    redirect '/quotes'
  else
    haml :quote_edit
  end
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

helpers do
  def render_comment(quote)
    author = Author.get(quote.author)
    "<img src='#{author.avatar}' /><span class='name'>#{author.name}</span><span class='comment'>#{quote.body}</span>"
  end
end

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


@@ quote_index
%div.title Quote Index
%a{:href => 'quotes/edit'} Add
- Quote.all.each do |quote|  
  .quote
    .quote_info
      %posted_by=quote.posted_by
      %date=quote.quote_date
    = render_comment(quote)
    


@@ quote_edit
%div.title Quote Edit
= @quote.errors.inspect unless @quote.errors.nil?
%form{ :action => "", :method => "post"}
  %fieldset
    %ol
      %li
        %label{:for => "author"} Name:
        %select{:name =>  "author"}
          - for author in Author.all
            %option{:selected => @quote.author, :value => author.id} #{author.name}
      %li
        %label{:for => "quote_date"} Date:
        %input{:type => "text", :name => "quote_date", :class => "text", :value => @quote.quote_date}
      %li
        %label{:for => "body"} Comment:
        %textarea{:name => "body", :value => @quote.body}        
      %li
        %label{:for => "posted_by"} Name:
        %select{:name =>  "posted_by"}
          - for author in Author.all
            %option{:selected => @quote.posted_by, :value => author.id} #{author.name}

    %input{:type => "submit", :value => "Send", :class => "property"}