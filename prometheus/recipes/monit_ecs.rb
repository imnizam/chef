# ecs-exporter
# https://github.com/slok/ecs-exporter

docker_image 'slok/ecs-exporter'

docker_container 'prom_ecs_exporter' do
  container_name 'prom_ecs_exporter'
  repo 'slok/ecs-exporter'
  restart_policy 'on-failure'
  command '-aws.region="us-west-2"'
  port '9222:9222'
  action :run
end

include_recipe 'aws::ec2_hints'

Chef::Log.info("******Add host tags.******")

instance_info = Chef::HTTP.new('http://169.254.169.254/latest/dynamic/instance-identity/document').get('/')
instance_id = JSON.parse(instance_info)['instanceId']

aws_resource_tag instance_id do
  tags('prometheus_ecs' => '')
  action :update
end