require './ci/common'

namespace :ci do
  namespace :core_integration do |flavor|
    task :before_install => ['ci:common:before_install']

    task :install => ['ci:common:install']

    task :before_script => ['ci:common:before_script']

    task :script => ['ci:common:script'] do
      this_provides = [
        'core_integration'
      ]
      Rake::Task['ci:common:run_tests'].invoke(this_provides)
    end

    task :before_cache => ['ci:common:before_cache']

    task :cache => ['ci:common:cache']

    task :cleanup => ['ci:common:cleanup']

    task :execute do
      exception = nil
      begin
        %w(before_install install before_script script).each do |t|
          Rake::Task["#{flavor.scope.path}:#{t}"].invoke
        end
      rescue => e
        exception = e
        puts "Failed task: #{e.class} #{e.message}".red
      end
      if ENV['SKIP_CLEANUP']
        puts 'Skipping cleanup, disposable environments are great'.yellow
      else
        puts 'Cleaning up'
        Rake::Task["#{flavor.scope.path}:cleanup"].invoke
      end
      fail exception if exception
    end
  end
end
