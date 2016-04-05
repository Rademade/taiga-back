set :repo_url, 'git@github.com-taiga-backend:Rademade/taiga-back.git'

set :deploy_to, "/home/taiga/website-production/backend"

server '138.201.48.226', user: 'taiga', roles: %w{web app}

set :branch, 'master'
