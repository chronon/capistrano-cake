# ==============================================================================
# Required settings
# ==============================================================================
set :application, "mygreatapp.com"
set :repository,  "ssh://mygitrepo.com/home/git/repos/mygreatapp.com"
set :deploy_to, "/var/www/#{application}"
set :branch, "master"
role :web, "myownserver.com"

# ==============================================================================
# Optional settings
# ==============================================================================
set :cakephp_site, true
set :cake_config_files, %w{core.php database.php bootstrap.php}
# set :cake_shared_dirs, %w{tmp Vendor Plugin} # these are the defaults
set :upload_dirs, %w{img/contents img/options files/downloads}
set :compile_css, true
set :compile_js, true
set :files_to_remove, %w{webroot/css/cake*.css webroot/img/cake.* webroot/img/test-*.png webroot/test.php}

# ==============================================================================
# Staging specific settings (overrides any production settings)
# ==============================================================================
task :staging do
  set :repository,  ""
  set :deploy_to, ""
  set :branch, "staging"
end
