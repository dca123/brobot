require 'mongoid'
require './app/point'
Mongoid.load!('./db/database.yml', :development)
Point.collection.drop
usernames = ['@eh263', '@devinda', '@riceat', '@tamzyk', '@jabfrc', '@ldgyhp', '@multithermal']
reason = ['Bacon ipsum dolor amet flank drumstick filet mignon', 'Turducken strip steak leberkas short loin ',
  'Ribeye t-bone venison drumstick', 'Turkey cupim strip steak pancetta pi',
  'Turkey strip steak meatball, ball tip short loin boudin ground round brisket',
  'Flank kevin turducken sausage.', 'Cupim leberkas meatloaf capicola spare ribs kielbasa']

def rand_in_range(from, to)
  rand * (to - from) + from
end




100.times do
  giver = usernames.sample
  reciever = usernames.sample
  while giver == reciever
    giver = usernames.sample
    reciever = usernames.sample
  end
  Point.create(giver: giver ,reciever: reciever, points: rand(5..50),reason: reason.sample, ts: Time.at(rand_in_range(2.weeks.ago.to_f, Time.now.to_f)))
end
