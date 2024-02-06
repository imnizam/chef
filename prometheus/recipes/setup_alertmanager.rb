# Find peer instances in same layer
instance = search("aws_opsworks_instance", "self:true").first
Chef::Log.info("********** For instance '#{instance['hostname']}:#{instance['instance_id']}', the instance's private IP address is '#{instance['private_ip']}' **********")

my_layerid = instance['layer_ids'][0]
my_hostname = instance['hostname']
my_dns = "#{my_hostname}.myorg.vpc"
my_peers = Array.new

search("aws_opsworks_instance").each do |i|
  if i['layer_ids'].include?(my_layerid)
    my_peers << i['hostname']
  end
end

my_peers.delete(my_hostname)
config_arg = " "

my_peers.each do |pr|
  config_arg += " --cluster.peer=#{pr}:6783 "
end

Chef::Log.info("********** For instance #{instance['hostname']}, peered instances are #{my_peers} **********")

include_recipe 'prometheus::install_docker'

# Change ownership of attached EBS volume at /prometheus
directory '/alertmanager' do
  owner 'nobody'
  group 'nogroup'
  mode 00755
  action :create
end

# Copy alertmanager.yml
template "/alertmanager/alertmanager.yml" do
  source "alertmanager/alertmanager.yml.erb"
  owner "nobody"
  group "nogroup"
  mode "0644"
end

# Pull alertmanager docker image
docker_image 'prom/alertmanager'

# Run alertmanager in custom network
docker_container 'alertmanager' do
  container_name 'alertmanager'
  repo 'prom/alertmanager'
  privileged true
  restart_policy 'on-failure'
  command "--config.file=/etc/alertmanager/alertmanager.yml #{config_arg} --cluster.listen-address=:6783 --web.external-url=http://#{my_dns}:9093"
  volumes ['/alertmanager/:/etc/alertmanager/', '/etc/hosts:/etc/hosts']
  port ['6783:6783','9093:9093']
  labels ['service:prometheus-am']
  action :run
end