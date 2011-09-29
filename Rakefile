# Rakefile to build a project using HUDSON

require 'rake/rdoctask'
require 'rake/clean'
require 'rake/gempackagetask'

PROJ_NAME = "typhon"
PROJ_FILES = ["pkg/doc", "bin", "#{PROJ_NAME}.spec", "#{PROJ_NAME}.init", "lib", "etc", "COPYING"]
PROJ_DOC_TITLE = "Typhon - File tail daemon"
PROJ_VERSION = File.read("VERSION").chomp
PROJ_RELEASE = "1"
PROJ_RPM_NAMES = [PROJ_NAME]

ENV["RPM_VERSION"] ? CURRENT_VERSION = ENV["RPM_VERSION"] : CURRENT_VERSION = PROJ_VERSION
ENV["BUILD_NUMBER"] ? CURRENT_RELEASE = ENV["BUILD_NUMBER"] : CURRENT_RELEASE = PROJ_RELEASE

CLEAN.include("build")

def announce(msg='')
  STDERR.puts "================"
  STDERR.puts msg
  STDERR.puts "================"
end

def init
    FileUtils.mkdir("pkg") unless File.exist?("pkg")
end

spec = Gem::Specification.new do |s|
  s.name = "typhon"
  s.version = PROJ_VERSION
  s.author = "R.I.Pienaar"
  s.email = "rip@devco.net"
  s.homepage = "https://github.com/ripienaar/typhon/"
  s.summary = "Wrapper around eventmachine-tail to make writing custom logtailers easy"
  s.description = "Single daemon that tails many files and route lines through your own logic"
  s.files = FileList["{bin,lib}/**/*"].to_a
  s.require_path = "lib"
  s.test_files = FileList["spec/**/*"].to_a
  s.has_rdoc = true
  s.executables = "typhon"
  s.default_executable = "typhon"
end

Rake::GemPackageTask.new(spec) do |build|
  build.need_tar = true
end

desc "Build documentation, tar balls and rpms"
task :default => [:clean, :doc, :archive, :rpm, :gem] do
end

# taks for building docs
rd = Rake::RDocTask.new(:doc) { |rdoc|
    announce "Building documentation for #{CURRENT_VERSION}"

    rdoc.rdoc_dir = 'pkg/doc'
    rdoc.template = 'html'
    rdoc.title    = "#{PROJ_DOC_TITLE} version #{CURRENT_VERSION}"
    rdoc.options << '--line-numbers' << '--inline-source' << '--main=Angelia'
}

desc "Create a tarball for this release"
task :archive => [:clean, :doc] do
    announce "Creating #{PROJ_NAME}-#{CURRENT_VERSION}.tgz"

    FileUtils.mkdir_p("pkg/#{PROJ_NAME}-#{CURRENT_VERSION}")
    system("cp -R #{PROJ_FILES.join(' ')} pkg/#{PROJ_NAME}-#{CURRENT_VERSION}")
    system("cd pkg && /bin/tar --exclude .svn -cvzf #{PROJ_NAME}-#{CURRENT_VERSION}.tgz #{PROJ_NAME}-#{CURRENT_VERSION}")
end

desc "Creates a RPM"
task :rpm => [:archive] do
    announce("Building RPM for #{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}")

    sourcedir = `/bin/rpm --eval '%_sourcedir'`.chomp
    specsdir = `/bin/rpm --eval '%_specdir'`.chomp
    srpmsdir = `/bin/rpm --eval '%_srcrpmdir'`.chomp
    rpmdir = `/bin/rpm --eval '%_rpmdir'`.chomp
    lsbdistrel = `/usr/bin/lsb_release -r -s|/bin/cut -d . -f1`.chomp
    lsbdistro = `/usr/bin/lsb_release -i -s`.chomp

    case lsbdistro
        when 'CentOS'
            rpmdist = "el#{lsbdistrel}"
        else
            rpmdist = ""
    end

    sh %{cp pkg/#{PROJ_NAME}-#{CURRENT_VERSION}.tgz #{sourcedir}}
    sh %{cp #{PROJ_NAME}.spec #{specsdir}}

    sh %{cd #{specsdir} && rpmbuild -D 'version #{CURRENT_VERSION}' -D 'rpm_release #{CURRENT_RELEASE}' -D 'dist .#{rpmdist}' -ba #{PROJ_NAME}.spec}

    sh %{cp #{srpmsdir}/#{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}.#{rpmdist}.src.rpm pkg/}

    sh %{cp #{rpmdir}/*/#{PROJ_NAME}*-#{CURRENT_VERSION}-#{CURRENT_RELEASE}.#{rpmdist}.*.rpm pkg/}
end

# vi:tabstop=4:expandtab:ai
