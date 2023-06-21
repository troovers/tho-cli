require 'open-uri'
require 'json'
require 'yaml'

module Commands
    class Config
        attr_accessor :version_check    

        def initialize(args)
            @version_check = args['version-check']
        end

        def execute
            puts colored :blue, "#{CHAR_FLAG} Updating your configuration preferences.."

            config = Settings.all

            if @version_check != nil
                puts colored :default, "#{CHAR_VERBOSE} Updating version-check to #{version_check == 'true'}" unless !$verbose
                config['version_check'] = version_check == 'true'
            end

            puts colored :default, "\n#{CHAR_VERBOSE} Writing updates to settings" unless !$verbose
            pp config unless !$verbose

            Settings.update(config)
        end
    end
end
