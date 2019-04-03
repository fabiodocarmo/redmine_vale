#!/bin/sh
git fetch $1 # busca o codigo do repositorio remoto
git reset --hard $1/$2  # faz rebase da branch passada no parâmetro
git submodule init # inicia os submodulos  novos
git submodule sync # atualiza as urls do submodule
git submodule update # atualiza os submodulos
bundle install --without development test # instala as novas gemas

rake db:migrate RAILS_ENV=production  # roda as migracoes do redmine
rake redmine:plugins:migrate RAILS_ENV=production # roda das migracoes dos plugins

# rake redmine:plugins:bpm_integration:stop_sync_bpm

# Should run 'foreman export systemd -u <usuario> /etc/systemd/system -a <nome aplicacao>' first
# Should run 'systemctl enable <nome aplicacao>.target' first

# sudo systemctl restart <nome aplicacao>.target 
sudo systemctl restart servicecenter.target

# rake redmine:plugins:bpm_integration:sync_bpm_tasks
# rake redmine:plugins:bpm_integration:sync_process_instances
