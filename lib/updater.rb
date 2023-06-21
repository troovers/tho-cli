require 'openssl'
require 'jwt'  
require 'net/http'

class Updater
    def self.check(silently=false)
        begin
            url = "https://raw.githubusercontent.com/troovers/tho-cli/main/latest_release.json"

            puts colored :default, "#{CHAR_VERBOSE} Fetching the latest release from Github:" unless !$verbose
            puts colored :default, "#{CHAR_VERBOSE} #{url}" unless !$verbose

            releaseName = (response['name'] || '0.1.0').tr('^0-9.', '')

            puts colored :default, "#{CHAR_VERBOSE} Latest version is: #{releaseName}" unless !$verbose
        rescue
            # Request failed, we fake an up to date installation
            puts colored :yellow, "#{CHAR_WARNING} Unable to retrieve the latest version, an error occurred" unless !$verbose

            return nil
        end

        # Compare versions 
        if !silently && Gem::Version.new(Tho::VERSION) < Gem::Version.new(releaseName)
            puts colored :yellow, "+-------------------------------------------------------+"
            puts colored :yellow, "| Tho Upgrade available                               |"
            puts colored :yellow, "+-------------------------------------------------------+"
            puts colored :yellow, " A new version is available for download: #{releaseName}"
            puts colored :yellow, " Run tho upgrade to install it\n"
        end

        return Gem::Version.new(Tho::VERSION) < Gem::Version.new(releaseName) ? response : nil
    end

    def self.update(newVersion)
        releaseName = (newVersion['name'] || '0.1.0').tr('^0-9.', '')

        puts colored :default, "#{CHAR_VERBOSE} Updating to the new version: #{releaseName}\n" unless !$verbose
        puts colored :default, "#{CHAR_VERBOSE} Getting the asset url" unless !$verbose

        downloadUrl = newVersion['download_url']

        unless downloadUrl
            warn colored :red, "\n#{CHAR_ERROR} Unable to locate download url from response"
            return
        end

        puts colored :default, "#{CHAR_VERBOSE} Asset url: #{downloadUrl}" unless !$verbose

        puts colored :blue, "\n#{CHAR_FLAG} Downloading.."

        filename = 'tho-latest.gem'
        open(filename, 'wb') do |file|
            file << URI.open(downloadUrl).read
        end

        puts colored :blue, "\n#{CHAR_FLAG} Finished download, installing.."
        puts colored :default, "#{CHAR_VERBOSE} gem install tho-latest.gem" unless !$verbose

        system("gem install '#{filename}'")

        # Remove the downloaded file again
        puts colored :default, "#{CHAR_VERBOSE} Deleting #{filename}" unless !$verbose
        File.delete(filename) if File.exist?(filename)

        puts colored :green, "\n#{CHAR_CHECK} Done! Your current version:"
        system("tho --version")
    end  
end