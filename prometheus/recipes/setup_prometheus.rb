include_recipe 'prometheus::install_docker'

# Change ownership of attached EBS volume at /prometheus
directory '/prometheus' do
  owner 'nobody'
  group 'nogroup'
  mode 00755
  action :create
end

# Copy prometheus.yml
template "/prometheus/prometheus.yml" do
  source "prometheus.yml.erb"
  owner "nobody"
  group "nogroup"
  mode "0644"
end

db_instance = node['prometheus']['pg_databse']

# create custom docker bridge network
docker_network 'prometheus' do
  driver 'bridge'
  action :create
end

# Pull prometheus docker image
docker_image 'prom/prometheus'

# Pull prometheus_postgresql_adapter docker image
docker_image 'timescale/prometheus-postgresql-adapter'

# Run prometheus in custom network
docker_container 'prometheus_server' do
  container_name 'prometheus_server'
  repo 'prom/prometheus'
  network_mode 'prometheus'
  restart_policy 'on-failure'
  command '--config.file=/prometheus/prometheus.yml --storage.tsdb.retention.time=8d --web.enable-lifecycle --web.enable-admin-api'
  volumes ['/prometheus:/prometheus']
  port '9090:9090'
  action :run
end

# Run prometheus_postgresql_adapter in custom network
docker_container 'prometheus_postgresql_adapter' do
  container_name 'prometheus_postgresql_adapter'
  repo 'timescale/prometheus-postgresql-adapter'
  network_mode 'prometheus'
  restart_policy 'on-failure'
  command "-pg.host=#{db_instance} -pg.prometheus-log-samples -leader-election.pg-advisory-lock-id=1 -leader-election.pg-advisory-lock.prometheus-timeout=6s"
  port '9201:9201'
  action :run
end

