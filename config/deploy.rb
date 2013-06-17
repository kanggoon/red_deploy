#set :stages, %w(development release qa staging production devsup tgs dev)
set :stages, %w(staging production admin dev)
set :default_stage, "dev"

set :application, "dooboo"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`


set :shared_children, %w(log config system player upload)

set :settings_dir, "config/settings"
set :setting_files, %w(databases.php gree.php)

namespace :deploy do
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    
    run "#{try_sudo} chmod o+w #{File.join(shared_path, 'log')}"
    
    put process_erb("config/settings/crossdomain.xml", binding), "#{shared_path}/system/crossdomain.xml"
  end
  
  def process_erb(filepath, bindings)
    if File.file?(filepath)
      template = File.read(filepath)
      processor = ERB.new(template)
      processor.result(bindings)
    end
  end
  
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{release_path}" if fetch(:group_writable, true)
    
  #  run_symlink "log", "log"
   # run_symlink "system/crossdomain.xml", "public/crossdomain.xml"
  #  run_symlink "upload", "public/upload"
#    run_symlink "upload_dev", "public/upload_dev"
   # run_symlink "admin", "public/admin"
  #  run_symlink "qa", "public/qa"
    #run_symlink "system", "public/system"
  end
  
  def run_symlink(source, target)
    run <<-CMD
      test -e #{shared_path}/#{source} &&
      rm -rf #{release_path}/#{target} &&
      ln -nfs #{shared_path}/#{source} #{release_path}/#{target}
    CMD
  end
end

set :keep_releases, 5
after "deploy:update", "deploy:cleanup"
