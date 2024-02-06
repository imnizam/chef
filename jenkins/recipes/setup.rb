#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2017, Nizam Uddin <nizam.hbti@gmail.com>
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'apt'
python_runtime '2' do
  pip_version '18.0'
end
include_recipe 'poise-python'
include_recipe 'java'


%w(jq unzip git-core supervisor nodejs logrotate).each do |pkg|
  package pkg do
    action :install
  end
end

%w(boto3 boto click arrow).each do |pkg|
  python_package pkg do
    action :install
  end
end

user 'jenkins' do
  home '/home/jenkins'
  manage_home true
  shell '/bin/bash'
  action :create
end
directory '/srv' do
  owner 'jenkins'
  group 'jenkins'
  mode 00777
  action :create
end
directory '/srv/jenkinstmp' do
  owner 'jenkins'
  group 'jenkins'
  mode 01777
  action :create
end
directory '/srv/backups' do
  owner 'jenkins'
  group 'jenkins'
  mode 00777
  action :create
end
directory '/srv/jenkins' do
  owner 'jenkins'
  group 'jenkins'
  mode 00777
  action :create
end
directory '/srv/docker' do
  owner 'root'
  group 'root'
  mode 00777
  action :create
end
directory '/etc/dd-agent/conf.d' do
  owner 'dd-agent'
  group 'root'
  mode '0755'
  recursive true
  action :create
end
template "/etc/dd-agent/conf.d/http_check.yaml" do
  source "dd_http_check.yaml.erb"
  owner "dd-agent"
  group "root"
  mode "0666"
end
template "/etc/dd-agent/conf.d/docker_daemon.yaml" do
  source "dd_docker_daemon.yaml.erb"
  owner "dd-agent"
  group "root"
  mode "0666"
end
directory '/root/scripts' do
  owner 'root'
  group 'root'
  mode '0777'
  recursive true
  action :create
end
cookbook_file  "/root/scripts/clear_docker_containers.sh" do
  source "clear_docker_containers.sh"
  mode "0755"
  owner "root"
  group "root"
end
cookbook_file  "/root/scripts/clear_docker_images.sh" do
  source "clear_docker_images.sh"
  mode "0755"
  owner "root"
  group "root"
end
cookbook_file  "/usr/local/bin/dns2" do
  source "dns2"
  mode "0755"
  owner "root"
  group "root"
end
cookbook_file  "/usr/bin/ecs-deploy" do
  source "ecs-deploy"
  mode "0755"
  owner "root"
  group "root"
end
cookbook_file  "/usr/bin/deploy_alb" do
  source "deploy_alb"
  mode "0755"
  owner "root"
  group "root"
end
bash 'install latest aws cli' do
  user 'root'
  code <<-EOH
    wget -P /tmp https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
    unzip -d /tmp /tmp/awscli-bundle.zip
    /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    rm -rf /tmp/awscli-bundle*
  EOH
  not_if { ::File.exists?('/usr/local/bin/aws') }
end

bash 'install_rvm' do
  user 'root'
  code <<-EOH
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    curl -sSL https://get.rvm.io | bash -s stable --ruby
    echo 'source /usr/local/rvm/scripts/rvm' >> /home/jenkins/.bashrc
    source /home/jenkins/.bashrc
    EOH
  not_if { ::File.exist?('/usr/local/rvm/scripts/rvm') }
end
%w(capistrano aws-sdk).each do |pkg|
  gem_package pkg do
    action :install
  end
end

directory '/etc/systemd/system/docker.service.d' do
  owner 'root'
  group 'root'
  mode '0777'
  recursive true
  action :create
end

bash 'install_docker' do
  user 'root'
  code <<-EOH
    curl -s https://releases.rancher.com/install-docker/18.09.6.sh | bash
    usermod -aG docker jenkins
  EOH
  not_if { ::File.exist?('/usr/bin/docker') }
end
service 'docker' do
  supports :status => true, :restart => true, :stop => true
end
template "/etc/systemd/system/docker.service.d/docker.conf" do
  source "docker.conf.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, 'service[docker]', :immediately
  not_if { ::File.exist?('/etc/systemd/system/docker.service.d/docker.conf') }
end

cron 'clear_docker_containers' do
  command "/bin/bash /root/scripts/clear_docker_containers.sh"
  minute '*/15'
  hour '*'
  day '*'
  month '*'
  weekday '*'
  action :create
  only_if do File.exist?('/root/scripts/clear_docker_containers.sh') end
end
cron 'clear_docker_images' do
  command "/bin/bash /root/scripts/clear_docker_images.sh"
  minute '*/15'
  hour '*'
  day '*'
  month '*'
  weekday '*'
  action :create
  only_if do File.exist?('/root/scripts/clear_docker_images.sh') end
end
# cron 'dns_setup' do
#   command "/usr/bin/ruby /usr/local/bin/dns2"
#   minute '*/3'
#   hour '*'
#   day '*'
#   month '*'
#   weekday '*'
#   action :create
#   only_if do File.exist?('/usr/local/bin/dns2') end
# end

cron 'log_rotate' do
  command "/usr/sbin/logrotate /etc/logrotate.conf"
  minute '*'
  hour '*'
  day '*'
  month '*'
  weekday '*'
  action :create
end
# install packer

bash 'install_packer' do
  user 'root'
  code <<-EOH
    wget -q https://releases.hashicorp.com/packer/1.4.3/packer_1.4.3_linux_amd64.zip
    mkdir -p /tmp/packer
    unzip -q packer_1.4.3_linux_amd64.zip -d /tmp/packer
    mv /tmp/packer/packer /usr/local/bin
    rm -rf /tmp/packer packer_1.4.3_linux_amd64.zip
    EOH
  not_if { ::File.exist?('/var/local/bin/packer') }
end




