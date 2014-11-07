Gem::Specification.new do |s|
  s.name = 'injection'
  s.version = '0.0.1'
  s.executables << 'injection'
  s.date = '2014-11-07'
  s.summary = "simple command line utility for patching project for InjectionForXcode and reverting it "
  s.description = "It lets you patch your project for XCode injection directly from command line rather than
using option in Xcode or AppCode menu, which generates a lot of alerts"
  s.authors = ["Michal Lukasiewicz"]
  s.email = 'michal.lukasiewicz@brightinventions.pl'
  s.files = ["lib/injection.rb"]
  s.homepage = 'https://github.com/bright/injection'
  s.license = 'MIT'
end