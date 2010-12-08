Capistrano::Configuration.instance.load do
  namespace :cached_submodules do
    desc "Fetch GIT submodules to shared folder and make links to it"
    task :fetch do
      run "cd #{release_path} && rake cached_submodules:fetch RAILS_ENV=#{rails_env} CACHED_SUBMODULES_DIR='#{shared_path}/submodules'"
    end
  end
end
