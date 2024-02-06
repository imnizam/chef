#
# Cookbook Name:: jenkins::server
# Recipe:: default
#
# Copyright 2017, Nizam Uddin <nizam.hbti@gmail.com>
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'jenkins::setup'

bash 'install_jenkins_server' do
  user 'root'
  code <<-EOH
    wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
    echo deb https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list
    apt-get update
    EOH
  not_if { ::File.exist?('/var/lib/jenkins') }
end

%w(jenkins).each do |pkg|
  package pkg do
    action :install
  end
end
template "/etc/default/jenkins" do
  source "jenkins.erb"
  owner "root"
  group "root"
  mode "0666"
end
service "jenkins" do
  action :restart
  supports :start => true, :stop => true, :restart => true
  only_if do
    File.exists?("/etc/init.d/jenkins")
  end
end
bash 'port_forward_80_to_8080' do
  user 'root'
  code <<-EOH
    iptables -A PREROUTING -t nat -i ens5 -p tcp --dport 80 -j REDIRECT --to-port 8080
    iptables -t nat -I OUTPUT -p tcp -o lo --dport 80 -j REDIRECT --to-ports 8080
    EOH
  only_if do
    File.exists?("/etc/init.d/jenkins")
  end
end