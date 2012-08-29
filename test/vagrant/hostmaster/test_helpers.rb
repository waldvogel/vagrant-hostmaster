require 'generator'
require 'vagrant/hostmaster/ui/capture'

module Vagrant
  module Hostmaster
    module TestHelpers
      protected
        def assert_local_host_address_of(address, vm, hosts_file, message=nil)
          _wrap_assertion do
            hosts_file.open
            full_message = build_message(message,
                                          "Expected host address of ? for ?.\n?",
                                          address,
                                          vm.uuid,
                                          hosts_file.read
                                        )
            hosts_file.rewind
            assert_block(full_message) do
              hosts_file.grep(/# VAGRANT: #{vm.uuid} \(#{vm.name}\)$/).any? do |entry|
                scanner = StringScanner.new(entry.chomp)
                scanner.skip(/\s+/)
                scanner.scan(/[0-9.]+/) == address
              end
            end
          end
        end

        def assert_local_host_entries_for(vms, hosts_file)
          hostmaster_boxes.each do |name,box|
            assert_local_host_entry_for box[:vm], hosts_file
            assert_local_host_address_of box[:address], box[:vm], hosts_file
            assert_local_host_name_of box[:host_name], box[:vm], hosts_file
          end
        end

        def assert_local_host_entry_for(vm, hosts_file, message=nil)
          _wrap_assertion do
            hosts_file.open
            full_message = build_message(message,
                                          "Expected host entry for ? to exist.\n?",
                                          vm.uuid,
                                          hosts_file.read
                                        )
            hosts_file.rewind
            assert_block(full_message) do
              hosts_file.grep(/# VAGRANT: #{vm.uuid} \(#{vm.name}\)$/).any?
            end
          end
        end

        def assert_local_host_name_of(name, vm, hosts_file, message=nil)
          _wrap_assertion do
            hosts_file.open
            full_message = build_message(message,
                                          "Expected host name of ? for ?.\n?",
                                          name,
                                          vm.uuid,
                                          hosts_file.read
                                        )
            hosts_file.rewind
            assert_block(full_message) do
              hosts_file.grep(/# VAGRANT: #{vm.uuid} \(#{vm.name}\)$/).any? do |entry|
                scanner = StringScanner.new(entry.chomp)
                scanner.skip(/\s+/)
                scanner.skip(/[0-9.]+/)
                scanner.skip(/\s+/)
                scanner.scan(/[^\s#]+/) == name
              end
            end
          end
        end

        def assert_no_local_host_entries_for(vms, hosts_file)
          vms.each do |vm|
            assert_no_local_host_entry_for(vm, hosts_file)
          end
        end

        def assert_no_local_host_entry_for(vm, hosts_file, message=nil)
          _wrap_assertion do
            hosts_file.open
            full_message = build_message(message,
                                          "Expected host entry for ? to not exist.\n?",
                                          vm.uuid,
                                          hosts_file.read
                                        )
            hosts_file.rewind
            assert_block(full_message) do
              hosts_file.grep(/# VAGRANT: #{vm.uuid} \(#{vm.name}\)$/).empty?
            end
          end
        end

        def hostmaster_box(name, host_name, address, uuid)
          hostmaster_boxes[name] = {:name => name, :host_name => host_name, :address => address, :uuid => uuid}
          hostmaster_boxes
        end

        def hostmaster_boxes
          @boxes ||= {}
        end

        def hostmaster_config
          hostmaster_boxes.inject("") do |config,(name,box)|
            config << <<-EOF
              config.vm.define :#{name} do |box|
                box.vm.host_name = "#{box[:host_name]}"
                box.vm.network :hostonly, "#{box[:address]}"
              end
            EOF
          end
        end

        def hostmaster_env
          Vagrant::Environment.new(:cwd => vagrantfile(hostmaster_config), :ui_class => Vagrant::Hostmaster::UI::Capture).load!
        end

        def hostmaster_vms(env)
          env.vms.values.collect do |vm|
            box = hostmaster_boxes[vm.name]
            vm.stubs(:state).returns(:running)
            vm.stubs(:uuid).returns(box[:uuid])
            box[:vm] = Vagrant::Hostmaster::VM.new(vm)
          end
        end

        def write_local_host_entries(hosts_file, entries={})
          hostmaster_boxes.each do |name,box|
            entry = box.merge(entries[name] || {})
            hosts_file.puts "#{entry[:address]} #{entry[:host_name]} # VAGRANT: #{entry[:uuid]} (#{entry[:name]})"
          end
          hosts_file.fsync
          hosts_file
        end
    end
  end
end
