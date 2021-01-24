# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock "~> 3.15.0"

set :application, "zendesk-helper"
set :repo_url, "https://github.com/alexleskov/zendesk-helper.git"

ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, "/home/deplo/zendesk-helper"

append :linked_files, "config/secrets.yml"
append :linked_dirs, "log", "tmp"

# Default value for default_env is {}
set :default_env, RAILS_ENV: fetch(:stage)

namespace :deploy do
=begin
  task :start_helper do
    on roles(:all) do
      execute :sudo, :monit, 'start zd_helper_schedule'
    end
  end

  task :stop_helper do
    on roles(:all) do
      execute :sudo, :monit, 'stop zd_helper_schedule'
    end
  end

  task :restart_helper do
    on roles(:all) do
      execute :sudo, :monit, 'restart zd_helper_schedule'
    end
  end
=end
end

# before "deploy:restart_helper"
# after "deploy:finishing", "deploy:restart_helper"
