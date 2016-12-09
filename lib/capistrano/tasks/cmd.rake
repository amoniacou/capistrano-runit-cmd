include ::Capistrano::Runit

namespace :load do
  task :defaults do
    set :runit_cmd_run_template, nil
    set :runit_cmd_default_hooks, -> { true }
    set :runit_cmd_role, -> { :app }
    set :runit_cmds, -> { {} }
  end
end

namespace :deploy do
  before :starting, :runit_check_cmd_hooks do
    invoke 'runit:cmd:add_default_hooks' if fetch(:runit_cmd_default_hooks)
  end
end

namespace :runit do
  namespace :cmd do |cmd_namespace|
    # Helpers
    def collect_cmd_run_command(cmd)
      array = []
      array << env_variables
      array << "RAILS_ENV=#{fetch(:rails_env)}"
      array << "exec #{SSHKit.config.command_map[:bundle]} exec #{cmd}"
      array.compact.join(' ')
    end

    def generate_namespace_for_cmd(name, cmd, parent_task)
      my_namespace = "runit:cmd:#{name}"
      parent_task.application.define_task Rake::Task, "#{my_namespace}:setup" do
        setup_service("cmd_#{name}", collect_cmd_run_command(cmd))
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:enable" do
        enable_service("cmd_#{name}")
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:disable" do
        disable_service("cmd_#{name}")
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:start" do
        start_service("cmd_#{name}")
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:stop" do
        on roles fetch("runit_cmd_#{name}_role".to_sym) do
          runit_execute_command("cmd_#{name}", 'down')
        end
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:restart" do
        restart_service("cmd_#{name}")
      end
    end

    task :add_default_hooks do
      after 'deploy:check', 'runit:cmd:check'
      after 'deploy:updated', 'runit:cmd:stop'
      after 'deploy:reverted', 'runit:cmd:stop'
      after 'deploy:published', 'runit:cmd:start'
    end

    task :hook do |task|
      fetch(:runit_cmds).each do |key, value|
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        set "runit_cmd_#{name}_role".to_sym, -> { :app }
        generate_namespace_for_cmd(name, value, task)
      end
    end

    task :check do
      fetch(:runit_cmds).each do |key, value|
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        check_service('cmd', name)
      end
    end

    task :stop do
      fetch(:runit_cmds).each do |key, value|
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["runit:cmd:#{name}:stop"].invoke
      end
    end

    task :start do
      fetch(:runit_cmds).each do |key, value|
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["runit:cmd:#{name}:start"].invoke
      end
    end

    task :restart do
      fetch(:runit_cmds).each do |key, value|
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["runit:cmd:#{name}:restart"].invoke
      end
    end

  end
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'runit:cmd:hook'
end
