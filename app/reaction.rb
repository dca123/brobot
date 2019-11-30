class Reaction
  include Mongoid::Document
  field :username, type: String
  field :slack_ts, type: BigDecimal
  field :reaction_name, type: String

  index({slack_ts: 1})
end
