# Statsd Exporter

directory '/opt/prometheus' do
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

template "/opt/prometheus/statsd_mapping.yml" do
  source "statsd_mapping.yml.erb"
  owner "root"
  group "root"
  mode "0644"
end

tar_extract 'https://github.com/prometheus/statsd_exporter/releases/download/v0.8.1/statsd_exporter-0.8.1.linux-amd64.tar.gz' do
  target_dir '/opt/prometheus/'
  creates '/opt/prometheus/statsd_exporter'
  tar_flags [ '-P', '--strip-components 1' ]
end

case node['init_package']
when 'systemd'
  template "/etc/systemd/system/statsd_exporter.service" do
    source "statsd_exporter.service.erb"
    owner "root"
    group "root"
    mode "0644"
  end
else
  template "/etc/init/statsd_exporter.conf" do
    source "statsd_exporter.conf.erb"
    owner "root"
    group "root"
    mode "0644"
  end
end

service "statsd_exporter" do
  action :start
end

include_recipe 'aws::ec2_hints'

Chef::Log.info("******Add host tags.******")

instance_info = Chef::HTTP.new('http://169.254.169.254/latest/dynamic/instance-identity/document').get('/')
instance_id = JSON.parse(instance_info)['instanceId']

aws_resource_tag instance_id do
  tags('prometheus_statsd' => '')
  action :update
end