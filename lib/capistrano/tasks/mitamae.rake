set :mitamae_dry_run, false

namespace :mitamae do
  desc "mitamae dry-run"
  task 'dry-run' do
    set :mitamae_dry_run, true
    invoke 'mitamae:apply'
  end

  desc "mitamae apply"
  task :apply do
    on roles(:all) do |server|
      within current_path do
        recipes = server.roles.map {|r| "recipes/roles/#{r}.rb" }
        dry_run = []
        dry_run << '-n' if fetch(:mitamae_dry_run)
        host = server.hostname.split('.').first
        team_no = host[/\Aapp-(\d+)/, 1].to_i if host.start_with?('app-')
        environment = {
          'MITAMAE_ENVIRONMENT' => fetch(:stage),
          'MITAMAE_ROLES' => server.roles.to_a.join(' '),
          'MITAMAE_HOST'  => host,
          'MITAMAE_TEAM_NO' => team_no
        }
        with environment do
          execute :sudo, 'bin/mitamae-x86_64-linux', 'local', *dry_run, 'bootstrap.rb', *recipes
        end
      end
    end
  end
end
