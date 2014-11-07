require 'socket'
require 'securerandom'

class Injection

  def initialize
    home = Dir.home
    @resources = home + '/Library/Application Support/Developer/Shared/Xcode/Plug-ins/InjectionPlugin.xcplugin/Contents/Resources/'

    project_files = Dir.glob('./*.xcodeproj')

    if project_files.size != 1
      raise 'Zero or more than one project file found in current path. Make sure you run this script in XCode project directory '
    end

    @project_file = project_files[0]
  end

  def revert
    self.execute_command('revertProject.pl')
  end

  def patch
    self.execute_command('patchProject.pl')
  end

  def refresh
    self.revert
    self.patch
  end

  def my_first_public_ipv4
    Socket.ip_address_list.detect { |intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? }.ip_address
  end

  def execute_command(script_name)
    ip = self.my_first_public_ipv4
    puts "ip: #{ip}"

    backup_suffix = SecureRandom.hex
    mute_script 'common.pm', backup_suffix

    command = "\"#{@resources}#{script_name}\"  \"#{@resources}\" \"#{@project_file}\" \"\" \"\" i386 0 20 0 \"127.0.0.1 #{ip}\" 31444"
    system(command)

    unmute_script 'common.pm', backup_suffix
  end

  def mute_script(script_name, backup_suffix = '')
    path = "#{@resources}#{script_name}"
    bak_path = "#{path}_bak#{backup_suffix}"

    if File.exist?(bak_path)
      return
    end

    system("cp \"#{path}\" \"#{bak_path}\"")

    puts "path: #{path}"
    text = File.read(path)

    muting_definitions[script_name].each { |line|
      line.each { |to_replace, replacement|
        puts "to_replace: #{to_replace}"
        puts "replacement: #{replacement}"
        text.gsub! to_replace, replacement
      }

    }
    File.open(path, 'w') { |file| file.puts text }

  end

  def unmute_script(script_name, backup_suffix = '')
    path = "#{@resources}#{script_name}"
    bak_path = "#{path}_bak#{backup_suffix}"

    system("cp \"#{bak_path}\" \"#{path}\"")
    system("rm \"#{bak_path}\" ")
  end

  def convert_file(script_name, reverse)
    path = "#{@resources}#{script_name}"
    bak_path = "#{path}_bak"

    system("cp \"#{path}\" \"#{bak_path}\"")

    puts "path: #{path}"
    text = File.read(path)

    muting_definitions[script_name].each { |line|
      line.each { |to_replace, replacement|
        puts "to_replace: #{to_replace}"
        puts "replacement: #{replacement}"
        text.gsub! to_replace, replacement
      }

    }
    File.open(path, 'w') { |file| file.puts text }
  end

  def mute_all

    muting_definitions.each { |key, value|
      mute_script key
    }

  end

  def unmute_all

    muting_definitions.each { |key, value|
      unmute_script key
    }

  end

  def muting_definitions
    {'BundleInjection.h' => [{
                                 '[alert show];' => '/* REDACTED */'
                             }],
     'common.pm' => [{
                         'system "open \'$file\'";' => '# REDACTED ";'
                     }],
    }
  end

end

