require 'json'
require 'oauth'
require 'dotenv'

module Twitter

  Dotenv.load('../.env')

  def self.access_token
    consumer = OAuth::Consumer.new(
      ENV['CONSUMER_KEY'],
      ENV['CONSUMER_SECRET'],
      site: 'https://ads-api.twitter.com'
    )
    token_hash = {
      oauth_token: ENV['ACCESS_TOKEN'],
      oauth_token_secret:  ENV['ACCESS_TOKEN_SECRET']
    }
    OAuth::AccessToken.from_hash(consumer, token_hash)
  end

  def self.search_tweets_hashtags(hashtag)
    body_response = access_token.request(
      :get,
      "https://api.twitter.com/1.1/search/tweets.json?q=%23#{hashtag}&count=10"
    ).body
    tweets = JSON.parse(body_response)['statuses']
    tweets.map { |t| t['text'] }
  end

  def self.trends
    body_response = access_token.request(
      :get,
      'https://api.twitter.com/1.1/trends/place.json?id=468739'
    ).body
    trends = JSON.parse(body_response).first['trends']
    trends.map { |t| t['name'] }
  end

  def self.users(user)
    body_response = access_token.request(
      :get,
      "https://api.twitter.com/1.1/users/show.json?screen_name=#{user}"
    ).body
    JSON.parse(body_response)['description']
  end
end
