require 'open-uri'
require 'json'
require 'yaml'

module Commands
    class Config

        def initialize(category, args)
            @@category = category
            @@args = {}

            puts args

            if category == 'global'
                args = args.select { |key, value| ['version-check'].include?(key) && !value.nil?  }
            elsif category == 'strings'
                args = args.select { |key, value| ['length', 'symbols', 'digits'].include?(key) && !value.nil?  }
            end

            @@args = args.map { |k, v| [k.sub('-', '_'), v] }.to_h

            puts @@args
        end

        def execute
            puts colored :blue, "#{CHAR_FLAG} Updating your configuration preferences.."

            config = Settings.all

            if @@category == 'global'
                config = update_global_config(config)
            elsif @@category == 'strings'
                config = update_strings_config(config)
            end

            puts colored :default, "\n#{CHAR_VERBOSE} Writing updates to settings" unless !$verbose

            Settings.update(config)
        end

        def update_global_config(config)

            @@args.each do |key, value|
                puts colored :default, "#{CHAR_VERBOSE} Updating #{key} to #{value}" unless !$verbose

                if key == 'version_check'
                    config[key] = value == 'true'
                end
            end

            return config
        end

        def update_strings_config(config)
            unless config.key? 'string'
                config['strings'] = {}
            end

            @@args.each do |key, value|
                puts colored :default, "#{CHAR_VERBOSE} Updating #{key} to #{value}" unless !$verbose

                if key == 'length'
                    config['strings'][key] = value.to_i

                elsif key == 'symbols' || key == 'digits'
                    config['strings'][key] = value == 'true'

                end
            end

            return config
        end
    end
end
