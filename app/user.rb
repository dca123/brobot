class User
  include Mongoid::Document
  field :username, type: String
  field :points, type: Integer, default: 30
end
