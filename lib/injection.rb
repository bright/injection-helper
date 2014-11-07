class Injection


  def initialize
    home = Dir.home
    @resources = home + '/Library/"Application Support"/Developer/Shared/Xcode/Plug-ins/InjectionPlugin.xcplugin/Contents/Resources/'

    project_files = Dir.glob('./*.xcodeproj')

    if project_files.size != 1
      raise 'Zero or more than one project files found in path ' + project_files.join(',')
    end

    @project_file = project_files[0]

  end

  def revert
    self.execute_command('revertProject.pl')
  end

  def patch
    self.execute_command('pathProject.pl')
  end

  def refresh
    self.revert
    self.path
  end

  def execute_command(script_name)
    command = "#{@resources}#{script_name}  #{@resources} #{@project_file} \"\" \"\" i386 0 20 0 \"127.0.0.1 192.168.0.11\" 31444"
    system(command)
  end

end