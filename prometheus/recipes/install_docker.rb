# Docker installation
docker_installation_package 'default' do
  version "#{node['docker']['version']}"
  action :create
  package_options %q|--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all'| # if Ubuntu for example
end

docker_service_manager_systemd 'default' do
  log_driver 'syslog'
  storage_driver 'overlay2'
  bip '172.17.0.1/16'
  action :restart
end

template "/etc/logrotate.d/rsyslog" do
  source "logrotate-rsyslog.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/dd-agent/conf.d/docker_daemon.yaml" do
  source "docker_daemon.yaml"
  owner "root"
  group "root"
  mode "0644"
end

# add cron for logrotation
cron 'logrotate' do
  command '/usr/sbin/logrotate -f /etc/logrotate.conf'
end