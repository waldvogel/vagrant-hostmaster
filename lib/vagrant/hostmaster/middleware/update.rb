module Vagrant
  module Hostmaster
    module Middleware
      class Update
        def initialize(app, env)
          @app = app
        end

        def call(env)
          update env[:vm]
          @app.call(env)
        end

        protected
          def update(vm)
            Hostmaster::VM.new(vm).update
          end
      end
    end
  end
end