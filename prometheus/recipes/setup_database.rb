# Note: add EBS volume and mount at /prometheus

include_recipe 'prometheus::install_docker'

docker_image 'timescale/pg_prometheus' do
  tag 'latest'
  action :pull
end

docker_container 'prometheus_pgsql_db' do
  container_name 'prometheus_pgsql_db'
  repo 'timescale/pg_prometheus'
  tag 'latest'
  restart_policy 'on-failure'
  command 'postgres -c synchronous_commit=off'
  env ["PGDATA=/prometheus"]
  volumes ['/prometheus:/prometheus']
  port '5432:5432'
  action :run
end