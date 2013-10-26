module Support
  module DiceBagHelpers
    def stub_dice_bag_templates(env_vars = nil)
      require 'rake'
      require 'dice_bag/tasks'
      
      env_vars ||= {
        wormhole_base_uri: 'http://rspec-example:9292'
      }
      
      template_path =  'tmp'
      Dir.mkdir(template_path) unless File.exists?(template_path)
        
      Farscape::DiceBag::Template.stub(:templates_location).and_return(template_path)

      run_dice_bag_tasks(env_vars, template_path)
    end

    def run_dice_bag_tasks(env_vars, template_path)
      require 'rake'
      require 'dice_bag/tasks'

      # Remove existing farscape.rb from a previous run so overwrite confirmation doesn't appear.
      system("rm #{template_path}/farscape.rb")

      Rake::Task['config:generate_all'].invoke
      system("bundle exec rake config:file[\"#{template_path}/farscape.rb.dice\"] #{env_var_portion(env_vars)}")
    end

    def dice_bag_env_name(name)
      "PRODUCTION_#{name.upcase}"
    end

    def env_var_portion(env_vars)
      env_vars.inject('') { |h, kv| h << "#{dice_bag_env_name(kv.first)}=#{kv.last} " }
    end
  end
end
