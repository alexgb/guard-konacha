module Guard
  class Konacha
    class Server < Rack::Builder

      def self.new
        super do
          use CacheBuster
          run ::Konacha.application
        end
      end

      class CacheBuster

        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, body = @app.call(env)

          headers.delete('Last-Modified')
          headers.delete('ETag')
          headers.delete('Cache-Control')

          [status, headers, body]
        end

      end

    end
  end
end
