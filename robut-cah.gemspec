Gem::Specification.new do |s|
  s.name = "robut-cah"
  s.version = "0.0.1"
  s.description = 'Cards plugin for Robut'
  s.summary = 'Cards plugin for Robut'

  s.add_dependency "robut"
  s.add_dependency "cah"
  s.license = "MIT"

  s.authors = ["Kyle Rippey", "Jeff Ching"]
  s.email = "kylerippey@gmail.com"
  s.homepage = "http://github.com/kylerippey/robut-cah"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir.glob('test/*_test.rb')
end
