namespace :cached_submodules do
  desc "Fetch submodules to shared/submodules"
  task :fetch do
    abort('not found .gitsubmodules file.') if !File.exists?(".gitmodules")

    # get paths and hashes of not initialized submodules
    git_submodule_status = `git submodule status`
    git_submodules = git_submodule_status.split("\n").map do |submodule_status_line|
      # Each SHA-1 will be prefixed with - if the submodule is not initialized
      match = submodule_status_line.match(/^-([0-9a-z]+) (\S+).*/)
      if match
        { :hash => match[1], :path => match[2] }
      end
    end
    git_submodules.compact!

    if git_submodules.empty?
      puts "no uninitialized submodules. done."
      exit
    end

    # get repo urls
    current_path = ""
    gitmodules_file = File.read(".gitmodules")
    gitmodules_file.each_line do |line|
      next if line.strip.index('#') == 0 || line.strip.empty?
      if line.include? "="
        key, val = line.split("=").map{|s| s.strip}
        current_path = val if key == "path"
        current_submodule = git_submodules.find{|s| s[:path] == current_path}
        current_submodule.update(:url => val) if key == "url" && current_submodule
      end
    end

    git_submodules.each do |submodule|
      submodule_hash = submodule[:hash]
      submodule_path = File.expand_path(submodule[:path])
      submodule_name = File.basename(submodule_path)
      submodule_url = submodule[:url]

      if ENV['CACHED_SUBMODULES_DIR']
        submodule_dir = File.expand_path(File.join(ENV['CACHED_SUBMODULES_DIR'], submodule_name, submodule_hash))
      else
        submodule_dir = File.expand_path("../shared/submodules/#{submodule_name}/#{submodule_hash}")
      end

      if Dir[ File.join(submodule_path, '*') ].any?
        puts "skip creating already exists #{submodule_path}"
      else
        if File.exists?(submodule_dir)
          puts "skip fetching already exists #{submodule_dir}"
        else
          puts "create #{submodule_dir}"
          FileUtils.mkdir_p(submodule_dir)

          puts "clone #{submodule_url} to #{submodule_dir}"
          system "git clone -q #{submodule_url} #{submodule_dir}"
        end
        puts "checkout #{submodule_hash}"
        `cd #{submodule_dir} && git checkout -q #{submodule_hash} && cd -`

        puts "make link #{submodule_path} -> #{submodule_dir}"
        system "rm -rf #{submodule_path} && ln -sF #{submodule_dir} #{submodule_path}"
      end
    end # each
  end
end