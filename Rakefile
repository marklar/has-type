require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/contrib/sshpublisher'

PKG_NAME      = 'glyde-hastype'
PKG_VERSION   = '0.1'  # update!

# What are these used for?
PKG_BUILD     = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
RELEASE_NAME  = "REL #{PKG_VERSION}"

# Add examples dir with some examples!

spec = Gem::Specification.new do |s|
  # -- Provenance --
  s.author            = "Mark 'marklar' Wong-VanHaren"
  s.email             = "mark@glyde.com"
  s.homepage          = "http://glyde.com"    # change to lib's homepage?

  # -- Name --
  s.name              = PKG_NAME
  s.rubyforge_project = PKG_NAME
  s.version           = PKG_VERSION

  # -- Description --
  s.summary           = "HasType: Validated method signatures."
  s.description       = <<-EOF
    HasType allows you to provide method signatures in code.
    They are validated at runtime (or you may turn them off completely).
EOF

  # -- Files --
  # FileList: rake-only.  Excludes spurious junk (.svn, ~).
  s.files        = FileList['Rakefile', 'README', 'lib/**/*.rb', 'test/**/*', 'example/**/*'].to_a
  s.test_files   = Dir.glob('test/test_*.rb')
  s.require_path = 'lib'    # Adds to LOAD_PATH

  # -- Dependencies --
  s.platform          = Gem::Platform::RUBY
  # s.add_dependency()  # none

  # -- RDoc --
  s.has_rdoc         = false
  s.extra_rdoc_files = %w( README )
  s.rdoc_options.concat ['--main',  'README']
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end
