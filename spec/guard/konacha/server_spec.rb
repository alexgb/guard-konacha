require 'spec_helper'

describe Guard::Konacha::Server do

  describe ".new" do
    it "should use CacheBuster" do
      expect_any_instance_of(Guard::Konacha::Server).to receive(:use).with(Guard::Konacha::Server::CacheBuster)
      expect_any_instance_of(Guard::Konacha::Server).to receive(:run).with(::Konacha.application)
      Guard::Konacha::Server.new
    end
  end

  describe Guard::Konacha::Server::CacheBuster do
    include Rack::Test::Methods

    let(:app) do
      Guard::Konacha::Server::CacheBuster.new(lambda { |env|
        [
          200,
          {
            'Content-Type' => 'text/plain',
            'Last-Modified' => 'Wed, 09 Apr 2008 23:55:38 GMT',
            'ETag' => '123456789',
            'Cache-Control' => 'max-age=290304000, public'
          },
          ['Hello']
        ]
      })
    end

    it "should remove caching headers" do
      get "/"
      expect(last_response.headers['Last-Modified']).to be_nil
      expect(last_response.headers['ETag']).to be_nil
      expect(last_response.headers['Cache-Control']).to be_nil
    end
  end

end
