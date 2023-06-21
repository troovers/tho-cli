require 'open-uri'
require 'json'

module Commands
    class Upgrade
        def initialize(args)
            # 
        end

        def execute
            # Try to find the latest release on Github
            newVersion = Updater.check(true)

            if newVersion == nil
                puts colored :green, "#{CHAR_CHECK} You are already up to date!"
                return
            end

            Updater.update(newVersion)
        end
    end
end
