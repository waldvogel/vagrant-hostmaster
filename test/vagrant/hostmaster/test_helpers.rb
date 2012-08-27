require 'generator'

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
          hostmaster_boxes_with(vms) do |box,vm|
            assert_local_host_entry_for vm, hosts_file
            assert_local_host_address_of box[:address], vm, hosts_file
            assert_local_host_name_of box[:name], vm, hosts_file
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

        def hostmaster_box(name, address, uuid)
          hostmaster_boxes << {:name => name, :address => address, :uuid => uuid}
        end

        def hostmaster_boxes
          @boxes ||= []
        end

        def hostmaster_boxes_with(vms)
          each_box = hostmaster_boxes.each
          vms.each do |vm|
            yield each_box.next, vm
          end
        end

        def hostmaster_config
          count = 0
          @boxes.inject("") do |config,box|
            count += 1
            config << <<-EOF
              config.vm.define :box#{count} do |box|
                box.vm.host_name = "#{box[:name]}"
                box.vm.network :hostonly, "#{box[:address]}"
              end
            EOF
          end
        end

        def hostmaster_vms(env)
          index = 0
          env.vms.values.collect do |vm|
            vm.stubs(:state).returns(:running)
            vm.stubs(:uuid).returns(@boxes[index][:uuid])
            index += 1
            Vagrant::Hostmaster::VM.new(vm)
          end
        end

        def write_local_host_entries_for(vms, hosts_file, options={})
          each_address = (options[:addresses] || @boxes.collect { |box| box[:address] }).each
          each_name = (options[:names] || @boxes.collect { |box| box[:name] }).each
          each_uuid = (options[:uuids] || @boxes.collect { |box| box[:uuid] }).each
          vms.each do |vm|
            hosts_file.puts "#{each_address.next} #{each_name.next} # VAGRANT: #{each_uuid.next} (#{vm.name})"
          end
          hosts_file
        end
    end
  end
end
