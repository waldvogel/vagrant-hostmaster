module Vagrant
  module Hostmaster
    module UI
      class Capture < Vagrant::UI::Silent
        class << self
          def capture
            return @capture unless block_given?
            begin
              current, @capture = @capture, ""
              yield
              result = @capture
            ensure
              @capture = current
            end
          end

          def capture?
            @capture
          end
        end
        [:info, :warn, :error, :success].each do |method|
          class_eval <<-CODE
            def #{method}(message, *args)
              super(message)
              if self.class.capture?
                self.class.capture << message
                self.class.capture << "\n" unless message[-1,1] == "\n"
              end
            end
          CODE
        end
      end
    end
  end
end