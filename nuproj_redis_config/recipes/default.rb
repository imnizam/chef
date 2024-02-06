include_recipe 'apt'
include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  execute "restart Rails app #{application}" do
    cwd deploy[:current_path]
    command node[:opsworks][:rails_stack][:restart_command]
    action :nothing
  end

  template "#{deploy[:deploy_to]}/shared/config/redis.yml" do
    source "redis.yml.erb"
    mode "0644"
    group deploy[:group]
    owner deploy[:user]
    variables(
      :redis => deploy[:redis] || {},
      :environment => deploy[:rails_env]
    )

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      deploy[:redis][:host].present? && File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end