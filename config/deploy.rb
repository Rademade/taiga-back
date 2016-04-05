lock '3.4.0'

set :application, 'Taiga-backend'

set :scm, :git

set :rvm_type,          :system
set :rvm_ruby_version,  'ruby-2.3.0@taiga'

set :linked_dirs, %w{static attachments media}
set :linked_files, %w{settings/local.py}

set :keep_releases, 2

namespace :deploy do

  task 'pip:install' do
    on roles(:web) do
      within release_path do
        execute "cd #{release_path} && pip install -r requirements.txt"
      end
    end
  end

  task 'db:migrate' do
    on roles(:web) do
      within release_path do
        execute "cd #{release_path} && python manage.py migrate --noinput"
      end
    end
  end

  task 'translation:update' do
    on roles(:web) do
      within release_path do
        execute "cd #{release_path} && python manage.py compilemessages"
      end
    end
  end

  task 'static:update' do
    on roles(:web) do
      within release_path do
        execute "cd #{release_path} && python manage.py collectstatic --noinput"
      end
    end
  end

  task 'app:restart' do
    on roles(:web) do
      within release_path do
        execute "ps aux | grep -ie taiga-server | awk '{print $2}' | xargs kill -9"
        execute "cd #{release_path} && uwsgi --master --processes 4 --threads 2 --http :8522 --wsgi-file taiga/wsgi.py --daemonize taiga-server.log"
      end
    end
  end
  # 8522

  after :updated, 'deploy:pip:install'
  after :updated, 'deploy:db:migrate'
  after :updated, 'deploy:translation:update'
  after :updated, 'deploy:static:update'

  # On first load:
  # - python manage.py loaddata initial_user
  # - python manage.py loaddata initial_project_templates
  # - python manage.py loaddata initial_role
  # - python manage.py sample_data

  after :finishing, 'deploy:app:restart'
  after :finishing, 'deploy:cleanup'

end
