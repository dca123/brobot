class Point
  include Mongoid::Document
  field :giver, type: String
  field :reciever, type: String
  field :points, type: Integer
  field :reason, type: String
  field :ts, type: DateTime
  field :slack_ts, type: BigDecimal

  index({slack_ts: 1})
end
