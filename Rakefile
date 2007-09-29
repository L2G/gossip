#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-07-03.
#  Copyright (c) 2007. All rights reserved.

require 'hoe'

Dir.chdir('lib') do
  # Hack: This prevents requires of the same file looking 
  # different in tests and causing annoying warnings.
  require 'gossip/version'
end

PROJECT='gossip'
THIS_RELEASE=Gossip::Version


Hoe.new(PROJECT, THIS_RELEASE) do |p|
  p.rubyforge_name = PROJECT
  p.changes = "See History.txt"
  p.author = "Brian Marick"
  p.description = "Library to broadcast messages to multiple destinations + scripts that use it"
  p.summary = p.description
  p.email = "marick@exampler.com"
  p.extra_deps = [['s4t-utils', '>= 1.0.3'],
                  ['xmpp4r', '>= 0.3.1'],
                  ['tinder', '>= 0.1.4'],
                  ['snitch', '>= 0.1.1'],
                  ['twitter', '>= 0.2.0'],
                  ['user-choices', '>= 1.1.4'],
                 ]
  p.test_globs = "test/**/*tests.rb"
  p.rdoc_pattern = %r{README.txt|History.txt|lib/gossip.rb|lib/gossip/.+\.rb}
  p.url = "http://gossip.rubyforge.org"
  p.remote_rdoc_dir = 'rdoc'
end

require 's4t-utils/rake-task-helpers'
require 's4t-utils/os'

def assert_in(dir, taskname)
  unless Dir.pwd == dir
    puts "Run task '#{taskname}' from directory '#{dir}'."
    exit 1
  end
end

def confirmed_step(name)
  STDOUT.puts "** #{name} **"
  STDOUT.puts `rake #{name}`
  STDOUT.print 'OK? > '
  exit if STDIN.readline =~ /[nN]/
end

class HoeLike
  
  def pull(key)
    @keys[key] || raise("Missing key #{key.inspect}")
  end
  
  def initialize(keys)
    @keys = keys
    project = pull(:project)
    this_release = pull(:this_release)
    login = pull(:login)
    web_site_root = pull(:web_site_root)
    export_root = pull(:export_root)
    
    root = "svn+ssh://#{login}/var/svn/#{project}"
    project_exports = "#{export_root}/#{project}"
    
    desc "Run fast tests."
    task 'fast' do
      S4tUtils.run_particular_tests('test', 'fast')
    end
    
    desc "Run slow tests."
    task 'slow' do
      S4tUtils.run_particular_tests('test', 'slow')
    end
    
    desc "Upload all the web pages (as part of release)"
    task 'upload_pages' do | task |
      assert_in_dir(project_exports, task.name)
      exec = "scp -r #{web_site_root}/* #{login}:/var/www/gforge-projects/#{project}/"
      puts exec
      system(exec)
    end
    
    desc "Upload all the web pages (not as part of release)"
    task 'export_and_upload_pages' => 'export' do | task |
      Dir.chdir(project_exports) do
        exec = "scp -r #{web_site_root}/* #{login}:/var/www/gforge-projects/#{project}/"
        puts exec
        system(exec)
      end
    end

    desc "Tag release with current version."
    task 'tag_release' do
      from = "#{root}/trunk"
      to = "#{root}/tags/rel-#{this_release}"
      message = "Release #{this_release}"
      exec = "svn copy -m '#{message}' #{from} #{to}"
      puts exec
      system(exec)
    end
    
    desc "Export to #{project_exports}"
    task 'export' do 
      Dir.chdir(export_root) do
        rm_rf project
        exec = "svn export #{root}/trunk #{project}"
        puts exec
        system exec
      end
    end
    

    desc "Complete release of everything - asks for confirmation after steps"
    # Because in Ruby 1.8.6, Rake doesn't notice subtask failures, so it
    # won't stop for us.
    task 'release_everything' do  
      confirmed_step 'check_manifest'
      confirmed_step 'export'
      Dir.chdir(project_exports) do
        puts "Working in #{Dir.pwd}"
        confirmed_step 'test'
        confirmed_step 'upload_pages'
        confirmed_step 'publish_docs'
        ENV['VERSION'] = this_release
        confirmed_step 'release'
      end
      confirmed_step 'tag_release'
    end

  end

end

HoeLike.new(:project => PROJECT, :this_release => THIS_RELEASE,
            :login => "marick@rubyforge.org",
            :web_site_root => 'pages', 
            :export_root => "#{S4tUtils.find_home}/tmp/exports")


