#!/usr/bin/env ruby

# Copyright 2014-present One.com
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'logger'
require 'optparse'
require 'chef_diff/changeset'
require 'chef_diff/repo'

log = Logger.new(STDOUT)

options = {start_ref: nil, end_ref: 'HEAD'}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: chef_diff.rb [options] <repo_path>"

  opts.on("-v", "--verbose", "Run verbosely") do |v|

    # If -vv is supplied this block is executed twice
    if options[:verbosity]
      options[:verbosity] = Logger::DEBUG
    else
      options[:verbosity] = Logger::INFO
    end
  end

  opts.on('-s', '--start_ref REF', 'Git start reference') do |s|
    options[:start_ref] = s
  end

  opts.on('-e', '--end_ref REF', 'Git end reference (default HEAD)') do |e|
    options[:end_ref] = e
  end

end

optparse.parse!

repo_path = ARGV.pop

if not repo_path
  puts optparse
  exit(-1)
end

if options[:verbosity]
  log.level = options[:verbosity]
else
  log.level = Logger::WARN
end

chef_repo = ChefDiff::Repo.get('git', repo_path, log)
changeset = ChefDiff::Changeset.new(log, chef_repo, options[:start_ref],
                                    options[:end_ref],
                                    {:cookbook_dirs => ['cookbooks'],
                                     :role_dir => 'roles',
                                     :node_dir => 'nodes',
                                     :environment_dir => 'environments',
                                     :client_dir => 'clients',
                                     :databag_dir => 'data_bags'}
                                    )

puts
puts 'Node changes:'
puts '-------------'
puts changeset.nodes
puts

puts 'client changes:'
puts '---------------'
puts changeset.clients
puts

puts 'Environment changes:'
puts '--------------------'
puts changeset.environments
puts

puts 'Databag changes:'
puts '----------------'
puts changeset.databags
puts

puts 'Cookbook changes:'
puts '-----------------'
puts changeset.cookbooks
puts