require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://postgres:postgres@127.0.0.1/quotes_board')

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

DataMapper.finalize.auto_upgrade!
