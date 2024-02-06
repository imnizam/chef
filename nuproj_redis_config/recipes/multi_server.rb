include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  execute "restart Rails app #{application}" do
    cwd deploy[:current_path]
    command node[:opsworks][:rails_stack][:restart_command]
    action :nothing
  end

  file "#{deploy[:deploy_to]}/shared/config/redis_multi_server.yml" do
    content lazy {
        DexterRedisCookbook::Helpers.hash_to_yaml(deploy[:redis])
    }
    mode "0644"
    group deploy[:group]
    owner deploy[:user]

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      deploy[:redis][:host].present? && File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end