# node-exporter

directory '/opt/prometheus' do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

tar_extract 'https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz' do
  target_dir '/opt/prometheus/'
  creates '/opt/prometheus/node_exporter'
  tar_flags [ '-P', '--strip-components 1' ]
end

case node['init_package']
when 'systemd'
  template "/etc/systemd/system/node_exporter.service" do
    source "node_exporter.service.erb"
    owner "root"
    group "root"
    mode "0644"
  end
else
  template "/etc/init/node_exporter.conf" do
    source "node_exporter.conf.erb"
    owner "root"
    group "root"
    mode "0644"
  end
end
service "node_exporter" do
  action :start
end

include_recipe 'aws::ec2_hints'

Chef::Log.info("******Add host tags.******")

instance_info = Chef::HTTP.new('http://169.254.169.254/latest/dynamic/instance-identity/document').get('/')
instance_id = JSON.parse(instance_info)['instanceId']

aws_resource_tag instance_id do
  tags('prometheus_node' => '')
  action :update
end

# docker_image 'prom/node-exporter:v0.17.0'

# docker_container 'prom_system_monit' do
#   container_name 'prom_system_monit'
#   repo 'prom/node-exporter:v0.17.0'
#   restart_policy 'on-failure'
#   network_mode 'host'
#   pid_mode 'host'
#   command '--path.rootfs /host'
#   volumes ["/:/host:ro,rslave"]
#   action :run
# end