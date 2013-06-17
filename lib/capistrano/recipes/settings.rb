def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

_cset :setting_files,     ['database.yml']
_cset :settings_dir,      'config/deploy'

namespace :settings do
  desc <<-DESC
      Creates configuration files in shared path.

      Variables:
      setting_files: configuration files to create
      settings_dir: where configuration file templates are, default is 'config/deploy'.

      When this recipe is loaded, settings:setup is automatically configured \
      to be invoked after deploy:setup. You can skip this task setting \
      the variable :skip_settings_setup to true. This is especially useful \
      if you are using this recipe in combination with \
        capistrano-ext/multistaging to avoid multiple settings:setup calls \
      when running deploy:setup for all stages one by one.
  DESC
  task :setup, :except => { :no_release => true } do
    fetch(:setting_files, ['database.yml']).each do |filename|
      filepath = File.join( fetch(:settings_dir, "config/deploy"), filename)
      if File.file?(filepath)
        template = File.read(filepath)

        setting = ERB.new(template)

        run "mkdir -p #{shared_path}/config"
        run "mkdir -p #{shared_path}/config/#{File.dirname(filename)}" if File.dirname(filename) != "."
        put setting.result(binding), "#{shared_path}/config/#{filename}"
      end
    end
  end

  desc <<-DESC
  [internal] Updates the symlink for database.yml file to the just deployed release.
  DESC
  task :symlink, :except => { :no_release => true } do
    fetch(:setting_files, ['database.yml']).each do |filename|
      run "mkdir -p #{release_path}/config/#{File.dirname(filename)}" if File.dirname(filename) != "."
      run "ln -nfs #{shared_path}/config/#{filename} #{release_path}/config/#{filename}"
    end
  end
end

after "deploy:setup",           "settings:setup"   unless fetch(:skip_settings_setup, false)
after "deploy:finalize_update", "settings:symlink"
