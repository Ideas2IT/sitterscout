set :application, "sitterscout"
set :repository,  "http://glific.svnrepository.com/svn/sitterscout"
set :user, 'root'
# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/root/public_html/#{application}"
# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
# set :port, 30000
set :location, "sitterscout.com"

role :app, location
role :web, location
role :db,  location, :primary => true

# set :deploy_via, :copy

set :runner, user

task :after_symlink, :roles => :app do
    run "chmod -R 755 #{current_path}/tmp"
    run "ln -nfs /root/public_html/sitterscout/shared/public/photos /root/public_html/sitterscout/current/public/"
    run "chown -R www-data:www-data #{current_path}/"
    run "chown -R www-data:www-data #{shared_path}/"
end