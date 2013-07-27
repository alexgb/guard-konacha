require 'spec_helper'

describe Guard::Konacha::Server do

  describe ".new" do
    it "should use CacheBuster" do
      Guard::Konacha::Server.any_instance.should_receive(:use).with(Guard::Konacha::Server::CacheBuster)
      Guard::Konacha::Server.any_instance.should_receive(:run).with(::Konacha.application)
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
      last_response.headers['Last-Modified'].should be_nil
      last_response.headers['ETag'].should be_nil
      last_response.headers['Cache-Control'].should be_nil
    end
  end

end
