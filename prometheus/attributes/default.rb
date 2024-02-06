# Docker version
node.default['docker']['version'] = '18.09.2'

# prom_server

node.default['prometheus']['retention_period'] = "30d"
# prom_db

node.default['prometheus']['pg_databse'] = "prometheus-db1"

# grafana
node.default['prometheus']['grafana']['db']             = "<grafana db>"
node.default['prometheus']['grafana']['root_url']       = "http://grafana.myorg.vpc"
node.default['prometheus']['grafana']['s3_bucket']      = "dexter-monitoring-grafana"
node.default['prometheus']['grafana']['aws_region']     = 'us-west-2'
node.default['prometheus']['grafana']['s3_access_key']  = ''
node.default['prometheus']['grafana']['s3_secret_key']  = ''
node.default['prometheus']['grafana']['s3_bucket_path'] = 'grafana/'
