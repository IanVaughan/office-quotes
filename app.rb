require 'sinatra'
require 'haml'
require 'data_mapper'

class MyApp < Sinatra::Application
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://postgres:postgres@127.0.0.1/quotes_board')
  
  set :public_folder, File.dirname(__FILE__) + '/static'
  set :haml, :format => :html5

  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == 'foo' && password == 'bar'
  end

  get '/' do
    haml :index
  end

  get '/quotes' do
    haml :quotes_index
  end

  get '/quote/edit' do
    @quote = Quote.new
    haml :quote_edit
  end

  get '/quote/edit/:id' do
    @quote = Quote.get(params[:id])

    @comments = Comment.all(:quote => @quote.id, :order => [ :id ])

    haml :quote_edit
  end

  post '/quote/edit' do
    @quote = params[:id].nil? ? Quote.new : Quote.get(params[:id])
    @quote.person = params[:person]
    @quote.comment = params[:comment]
    @quote.quote_date = params[:quote_date]
    @quote.posted_by = params[:posted_by]

    if @quote.save
      redirect "/quote/edit/#{@quote.id}"
    else
      haml :quote_edit
    end
  end

  post '/quote/:id/comments' do
    @comment = Comment.new
    @comment.quote = params[:id]
    @comment.person = params[:person]
    @comment.comment = params[:comment]
    @comment.save
    
    redirect "quote/edit/#{params[:id]}"
  end

  get '/people' do
    haml :people_index
  end

  get '/person/edit' do
    @person = Person.new
    haml :person_edit
  end

  get '/person/edit/:id' do
    @person = Person.get(params[:id])
    haml :person_edit
  end

  post '/person/edit' do
    @person = params[:id].nil? ? Person.new : Person.get(params[:id])
    @person.name = params[:name]
    @person.avatar = params[:avatar]

    if @person.save
      redirect '/people'
    else
      haml :person_edit
    end
  end

  post '/person/delete/:id' do
    Person.get(params[:id]).destroy

    redirect '/people'  
  end

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