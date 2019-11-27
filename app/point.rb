class Point
  include Mongoid::Document
  field :giver, type: String
  field :reciever, type: String
  field :points, type: Integer
  field :reason, type: String
end
