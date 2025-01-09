#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'

require 'listen'

def run_all_tests
  puts
  system('bundle exec ruby test/run.rb')
end

def run_test(fn)
  system("bundle exec ruby #{fn}")
end

listener = Listen.to('lib', 'test') do |modified, added, removed|
  puts '*' * 40

  fns = []

  modified.each { fns << it }
  added.each    { fns << it }
  removed.each  { fns << it }

  fns = fns.uniq
  puts "modified: #{fns.inspect}"
  puts '*' * 40

  if fns.size == 1 && fns.first =~ /test_/
    run_test(fns.first)
  else
    run_all_tests
  end
end

run_all_tests
listener.start
sleep
