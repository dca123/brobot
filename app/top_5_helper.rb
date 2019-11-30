require 'sinatra/base'
module Sinatra
  module TopPoint
    def topPointsString
      topPoints = Point.collection.aggregate([
        {
          '$group': { _id: "$reciever",
            totalPoints: { '$sum': "$points" }
            }
        },
        {
          '$sort': {totalPoints: -1}
        },
        {
          '$limit': 5
        }

      ])
      topPointString = ''
      topPoints.each do |user|
          topPointString << "<#{user['_id']}>: #{user['totalPoints']}, "
      end
      return topPointString[0..-3]
    end
  end
  helpers TopPoint
end
