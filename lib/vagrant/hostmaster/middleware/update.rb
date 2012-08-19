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
            # TODO: need to pass collection of other vms
            Hostmaster::VM.new(vm).update other_vms
          end
      end
    end
  end
end