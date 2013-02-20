require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://postgres:postgres@127.0.0.1/quotes_board')

class Quote
  include DataMapper::Resource

  property :id,         Serial
  property :person,     Integer, required: true
  property :comment,    Text,   required: true, :length => 1..255
  property :quote_date, DateTime
  property :posted_by,  String, required: true

  def self.update_or_create(params)
    quote = params[:id].nil? ? Quote.new : Quote.get(params[:id])
    quote.person = params[:person]
    quote.comment = params[:comment]
    quote.quote_date = params[:quote_date]
    quote.posted_by = params[:posted_by]
    quote
  end
end

class Comment
  include DataMapper::Resource

  property :id,         Serial
  property :quote,      Integer,  required: true
  property :person,     Integer,  required: true
  property :comment,    Text,     required: true, :length => 1..255

  def initialize(params)
    #(id, person, comment)
    self.quote = params[:id]
    self.person = params[:person]
    self.comment = params[:comment]
  end
end

class Person
  include DataMapper::Resource

  property :id,         Serial
  property :name,       String,     required: true, :length => 1..255
  property :avatar,     String,     :length => 255
end

DataMapper.finalize.auto_upgrade!
