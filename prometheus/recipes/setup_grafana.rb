include_recipe 'prometheus::install_docker'

# Vars
grafana_db          = node['prometheus']['grafana']['db']
grafana_root_url    = node['prometheus']['grafana']['root_url']
grafana_s3_bucket   = node['prometheus']['grafana']['s3_bucket']
grafana_aws_region  = node['prometheus']['grafana']['aws_region']
s3_access_key       = node['prometheus']['grafana']['s3_access_key']
s3_secret_key       = node['prometheus']['grafana']['s3_secret_key']
s3_path             = node['prometheus']['grafana']['s3_bucket_path']

# Pull grafana docker image
docker_image 'grafana/grafana' do
  tag '5.0.4'
  action :pull
end

# Mkdir on host system to be mounted inside container
directory '/var/lib/grafana' do
  owner 'root'
  group 'root'
  mode 0777
  action :create
end

directory '/etc/grafana/provisioning' do
  owner 'root'
  group 'root'
  mode 0777
  recursive true
  action :create
end

apt_package "python-dev"
apt_package "build-essential"
# Run container
docker_container 'grafana_server' do
  container_name 'grafana_server'
  tag '5.0.4'
  repo 'grafana/grafana'
  restart_policy 'on-failure'
  env ["GF_DATABASE_URL=#{grafana_db}", "GF_SERVER_ROOT_URL=#{grafana_root_url}", "GF_EXTERNAL_IMAGE_STORAGE_PROVIDER=s3", "GF_EXTERNAL_IMAGE_STORAGE_S3_BUCKET=#{grafana_s3_bucket}", "GF_EXTERNAL_IMAGE_STORAGE_S3_REGION=#{grafana_aws_region}", "GF_EXTERNAL_IMAGE_STORAGE_S3_ACCESS_KEY=#{s3_access_key}", "GF_EXTERNAL_IMAGE_STORAGE_S3_SECRET_KEY=#{s3_secret_key}", "GF_EXTERNAL_IMAGE_STORAGE_S3_PATH=#{s3_path}"]
  port '3000:3000'
  binds [ '/var/lib/grafana:/var/lib/grafana', '/etc/grafana/provisioning:/etc/grafana/provisioning' ]
  action :run
end
