module Vagrant
  module Hostmaster
    module Middleware
      class Update
        def initialize(app, env)
          @app = app
        end

        def call(env)
          @app.call(env)
          update env[:vm]
        end

        protected
          def update(vm)
            Hostmaster::VM.new(vm).update
          end
      end
    end
  end
end