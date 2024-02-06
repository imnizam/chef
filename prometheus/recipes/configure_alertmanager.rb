# Copy alertmanager.yml
template "/alertmanager/alertmanager.yml" do
  source "alertmanager/alertmanager.yml.erb"
  owner "nobody"
  group "nogroup"
  mode "0644"
end

execute 'reload_alertmanager' do
  command "/bin/bash -c 'curl -X POST  localhost:9093/-/reload'"
end