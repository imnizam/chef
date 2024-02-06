instance = search("aws_opsworks_instance", "self:true").first
nuproj_dns = "#{instance['hostname']}.myorg.vpc"
include_recipe 'prometheus::install_docker'

# Change ownership of attached EBS volume at /prometheus
directory '/prometheus/alert_rules' do
  owner 'nobody'
  group 'nogroup'
  mode 00755
  recursive true
  action :create
end

# Copy prometheus.yml
template "/prometheus/prometheus.yml" do
  source "prometheus/prometheus_tsdb.yml.erb"
  owner "nobody"
  group "nogroup"
  mode "0644"
end

remote_directory "/prometheus/alert_rules" do
  source 'alert_rules'
  files_owner 'nobody'
  files_group 'nogroup'
  files_mode '0766'
  action :create
  recursive true
end

retention_period = node['prometheus']['retention_period']

# Pull prometheus docker image
docker_image 'prom/prometheus'

# Run prometheus in custom network
docker_container 'prometheus_server' do
  container_name 'prometheus_server'
  repo 'prom/prometheus'
  restart_policy 'on-failure'
  command "--config.file=/prometheus/prometheus.yml --storage.tsdb.retention.time=#{retention_period} --web.enable-lifecycle --web.enable-admin-api --web.external-url=http://#{nuproj_dns}:9090/"
  volumes ['/prometheus:/prometheus', '/etc/hosts:/etc/hosts']
  port '9090:9090'
  labels ['service:prometheus']
  action :run
end
