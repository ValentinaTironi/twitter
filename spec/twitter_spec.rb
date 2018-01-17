require 'twitter_module.rb'
require 'webmock/rspec'

describe Twitter do
  describe '.prepare_access_token' do

    subject { described_class.prepare_access_token(token, secret) }
    let(:token) { ENV['ACCESS_TOKEN'] }
    let(:secret) { ENV['ACCESS_TOKEN_SECRET'] }

    context '.token' do
      it 'return the token access' do
        expect(subject.token).to eq(token)
      end
    end

    context '.secret' do
      it 'return the token access' do
        expect(subject.secret).to eq(secret)
      end
    end
  end

  describe '.search_tweets_hashtags' do

    subject { described_class.search_tweets_hashtags(hashtag) }

    context 'get correct response' do
      let(:text) { 'Hello world' }
      let(:body) do
        { statuses: [
          {
            created_at: 'Wed Jan 03 14:31:10 +0000 2018',
            id: 9_485,
            id_str: '9_485',
            text: text
          }
        ] }
      end
      let(:hashtag) { 'example' }
      before do
        stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json?count=10&q=%23#{hashtag}")
          .to_return(body: JSON(body))
      end
      it 'return the text from tweets' do
        expect(subject).to eq([text])
      end
    end

    context 'get an error in response' do
      let(:hashtag) { 'example' }
      let(:error) { NoMethodError }
      let(:body) do
        { errors: [
          { code: 215,
            message: 'Bad Authentication data.' }
        ] }
      end
      before do
        stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json?count=10&q=%23#{hashtag}")
          .to_return(body: JSON(body))
      end
      it 'raises an error' do
        expect { subject }.to raise_error(error)
      end
    end

    context 'get an response nil' do
      let(:hashtag) { 'example' }
      let(:text) { [] }
      let(:body) { { statuses: [] } }
      before do
        stub_request(:get, "https://api.twitter.com/1.1/search/tweets.json?count=10&q=%23#{hashtag}")
          .to_return(body: JSON(body))
      end
      it 'return an empty array' do
        expect(subject).to eq(text)
      end
    end
  end

  describe '.trends' do

    subject { described_class.trends }

    context 'get correct response' do
      let(:name) { '#example' }
      let(:body) do
        [{ trends:
          [{ name: name,
             url:   "http:\/\/twitter.com\/search?q=%23#{name}",
             query: "%23#{name}" }] }]
      end
      before do
        stub_request(:get, 'https://api.twitter.com/1.1/trends/place.json?id=468739')
          .to_return(body: JSON(body))
      end
      it 'return trends' do
        expect(subject).to eq([name])
      end
    end
  end

  describe '.users' do

    subject { described_class.users(user) }

    context 'get a correct response' do
      let(:user) { 'example' }
      let(:description) { 'It is a bio example' }
      let(:body) do
        {
          id: 852,
          name: 'Example',
          screen_name: user,
          description: description
        }
      end
      before do
        stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=#{user}")
          .to_return(body: JSON(body))
      end
      it "return user's bio" do
        expect(subject).to eq(description)
      end
    end

    context 'get an error in response' do
      let(:user) { 'example' }
      let(:error) { SocketError }
      before do
        stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=#{user}")
          .and_raise(error)
      end
      it 'raises an error' do
        expect { subject }.to raise_error(error)
      end
    end

    context 'user not found' do
      let(:user) { 'example' }
      let(:description) { nil }
      let(:body) do
        { errors: [
          { code: 50,
            message: 'User not found.' }
        ] }
      end
      before do
        stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=#{user}")
          .to_return(body: JSON(body))
      end
      it 'raises an error' do
        expect(subject).to eq(description)
      end
    end
  end
end
