require 'sinatra'
require 'haml'
require 'logger'  # only required to set log level
require 'json'
require './app/models/models'

class MyApp < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/static'
  set :haml, :format => :html5

  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == 'foo' && password == 'bar'
  end

  configure :development do
    set :logging, Logger::DEBUG
  end

  get '/' do
    haml :index
  end

  get '/quotes' do
    haml :quotes_index, :locals => {:quotes => Quote.all(:order => [ :id.desc ])}
  end

  get '/quote/edit' do
    haml :quote_edit, :locals => {:quote => Quote.new}
  end

  get '/quote/edit/:id' do
    haml :quote_edit, :locals => {:quote => Quote.get(params[:id])} # what if ID/quote is invalid?
  end

  get '/quote/:id/?.?:format?' do
    quote = Quote.get(params[:id])
    redirect '/' if quote.nil?
    comments = Comment.all(:quote => params[:id], :order => [ :id ])

    case params[:format]
    when 'json'
      content_type :json
      {:quote => quote, :comments => comments}.to_json
    else
      haml :quote_view, :locals => {:quote => quote}
    end
  end

  get '/random/?.?:format?' do
    #TODO: dont redirect as that changes the URL, keep it as /random
    redirect "/quote/#{rand(Quote.count-1)+1}/.#{params[:format]}"
  end

  post '/quote/edit' do
    quote = Quote.update_or_create(params)

    if quote.save
      redirect "/quote/edit/#{quote.id}"
    else
      quote.person = nil
      haml :quote_edit, :locals => {:quote => quote}
    end
  end

  post '/quote/:id/comments' do
    comment = Comment.new(params)
    #TODO: need a way of showing a error if a comment save fails
    unless comment.save
      # Quote.get(params[:id]).errors = {:comment => "BALLS"}
    end
    redirect "/quote/edit/#{params[:id]}"
  end


  # people / person

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

  get '/person/quotes/:id' do
    haml :quotes_index, :locals => {:quotes => Quote.all(:person => params[:id], :order => [ :id.desc ])}
  end

  helpers do
    def render_quote(quote)
      comments = Comment.all(:quote => quote.id, :order => [ :id ])

      html = render_comment(quote, true)
      comments.each do |comment|
        html += "<div class='comment'>#{render_comment(comment)}</div>"
      end
      html
    end

    def render_comment(quote, link = false)
      person = Person.get(quote.person)
      #TODO: make image and name link to person
      #TODO: make whole quote area link to view single quote
      html = "<img src='#{person.avatar}' />"
      html << "<a href='/person/quotes/#{person.id}'><span class='name'>#{person.name}</span></a>"
      html << "<a href='/quote/#{quote.id}'>" if link
      html << "<span class='text'>#{quote.comment}</span>"
      html << "</a>" if link
      html
    end
  end
end
