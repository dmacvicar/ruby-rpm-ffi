$LOAD_PATH.push(File.join(File.dirname(__FILE__), 'lib'))
require 'bundler/gem_tasks'
require 'rpm/gem_version'
require 'rake/testtask'

task default: [:test]

Rake::TestTask.new do |t|
  t.libs << File.expand_path('../test', __FILE__)
  t.libs << File.expand_path('../', __FILE__)
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
  t.loader = :direct
end

extra_docs = ['README*', 'TODO*', 'CHANGELOG*']

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.files   = ['lib/**/*.rb', *extra_docs]
    t.options = ['--no-private']
  end
rescue LoadError
  STDERR.puts 'Install yard if you want prettier docs'
  begin
    require 'rdoc/task'
    Rake::RDocTask.new(:doc) do |rdoc|
      rdoc.rdoc_dir = 'doc'
      rdoc.title = "rpm for Ruby #{RPM::GEM_VERSION}"
      extra_docs.each { |ex| rdoc.rdoc_files.include ex }
    end
  rescue LoadError
    STDERR.puts 'rdoc not available'
  end
end

desc "Build the docker images for test"
task :docker_images do
  Dir.glob('_docker/Dockerfile.*').each do |dockerfile|
    tag = 'ruby-rpm-ffi:' + File.extname(dockerfile).delete('.')
    sh %(podman build -f #{dockerfile} -t #{tag} .)
  end
end

desc "Run the tests from within the docker images"
task :docker_test do
  Dir.glob('_docker/Dockerfile.*').each do |dockerfile|
    tag = 'ruby-rpm-ffi:' + File.extname(dockerfile).delete('.')
    sh %(podman run -ti -v #{Dir.pwd}:/src #{tag} rake test)
  end
end
