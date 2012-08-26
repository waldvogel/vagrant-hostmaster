module Vagrant
  module Hostmaster
    module TestHelpers
      protected
        def assert_local_host_address_of(address, uuid, hosts_file, message=nil)
          _wrap_assertion do
            hosts_file.open
            full_message = build_message(message,
                                          "Expected host address of <?> for <?>.\n<?>",
                                          address,
                                          uuid,
                                          hosts_file.path
                                        )
            assert_block(full_message) do
              hosts_file.grep(/# VAGRANT: #{uuid} \(default\)$/).any? do |entry|
                scanner = StringScanner.new(entry.chomp)
                scanner.skip(/\s+/)
                scanner.scan(/[0-9.]+/) == address
              end
            end
          end
        end

        def assert_local_host_entry_for(uuid, hosts_file, message=nil)
          _wrap_assertion do
            hosts_file.open
            full_message = build_message(message,
                                          "Expected host entry for <?> to exist.\n<?>",
                                          uuid,
                                          hosts_file.path
                                        )
            assert_block(full_message) do
              hosts_file.grep(/# VAGRANT: #{uuid} \(default\)$/).any?
            end
          end
        end

        def assert_local_host_name_of(name, uuid, hosts_file, message=nil)
          _wrap_assertion do
            hosts_file.open
            full_message = build_message(message,
                                          "Expected host name of <?> for <?>.\n<?>",
                                          name,
                                          uuid,
                                          hosts_file.path
                                        )
            assert_block(full_message) do
              hosts_file.grep(/# VAGRANT: #{uuid} \(default\)$/).any? do |entry|
                scanner = StringScanner.new(entry.chomp)
                scanner.skip(/\s+/)
                scanner.skip(/[0-9.]+/)
                scanner.skip(/\s+/)
                scanner.scan(/[^\s#]+/) == name
              end
            end
          end
        end

        def assert_no_local_host_entry_for(uuid, hosts_file, message=nil)
          _wrap_assertion do
            hosts_file.open
            full_message = build_message(message,
                                          "Expected host entry for <?> to not exist.\n<?>",
                                          uuid,
                                          hosts_file.path
                                        )
            assert_block(full_message) do
              hosts_file.grep(/# VAGRANT: #{uuid} \(default\)$/).empty?
            end
          end
        end
    end
  end
end
