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

execute 'reload_prometheus' do
  command "/bin/bash -c 'curl -X POST  localhost:9090/-/reload'"
end