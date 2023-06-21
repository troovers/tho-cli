require 'openssl'
require 'jwt'  
require 'net/http'

class Updater
    def self.check(silently=false)
        begin
            url = "https://api.github.com/repos/UnlockAgency/flutter-cli/releases/latest"

            puts colored :default, "#{CHAR_VERBOSE} Fetching the latest release from Github:" unless !$verbose
            puts colored :default, "#{CHAR_VERBOSE} #{url}" unless !$verbose

            response = JSON.load(
                URI.open(url, 'Authorization' => "Bearer #{getAccessToken}")
            )

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

        downloadUrl = newVersion['assets']&.select { |a| a['browser_download_url'].end_with?('.gem') }&.map { |a| a['browser_download_url'] }&.first

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

    def self.getAccessToken
        puts colored :default, "#{CHAR_VERBOSE} Getting access token and expiration date from storage" unless !$verbose

        accessToken = Settings.get('installation_access_token')
        accessTokenExpirationTime = Settings.get('installation_access_token_expiration_time')

        if accessToken == nil || accessTokenExpirationTime == nil 
            puts colored :default, "#{CHAR_VERBOSE} Either installation_access_token or installation_access_token_expiration_time isn't set" unless !$verbose

            # Create a new access token
            return createAccessToken
        end

        # Check if the access token has expired, against now - 1 minute
        unless accessTokenExpirationTime < Time.now.to_i - 60
            puts colored :default, "#{CHAR_VERBOSE} Access token is still valid, returning token from storage" unless !$verbose

            return accessToken
        end

        puts colored :default, "#{CHAR_VERBOSE} Access token has expired" unless !$verbose

        return createAccessToken
    end
    
    def self.createJwt
        puts colored :default, "#{CHAR_VERBOSE} Creating JWT token" unless !$verbose

        filePath = File.join(File.dirname(__FILE__), '../keys/2023-05-24.github.pem')
        private_pem = File.read(filePath)
        private_key = OpenSSL::PKey::RSA.new(private_pem)

        payload = {
            # issued at time, 60 seconds in the past to allow for clock drift
            iat: Time.now.to_i - 60,
            # JWT expiration time (10 minute maximum)
            exp: Time.now.to_i + (10 * 60),
            # GitHub App's identifier
            iss: '338415'
        }

        puts colored :default, "#{CHAR_VERBOSE} JWT created" unless !$verbose

        JWT.encode(payload, private_key, "RS256")
    end

    def self.createAccessToken
        puts colored :default, "#{CHAR_VERBOSE} Creating access token" unless !$verbose

        jwtToken = createJwt

        url = "https://api.github.com/repos/UnlockAgency/flutter-cli/installation"
        puts colored :default, "#{CHAR_VERBOSE} Getting the installation ID from github" unless !$verbose
        puts colored :default, "#{CHAR_VERBOSE} #{url}" unless !$verbose

        # Get the installation ID of the app
        response = JSON.load(URI.open(url, 'Authorization' => "Bearer #{jwtToken}"))

        installationId = response['id']

        puts colored :default, "#{CHAR_VERBOSE} InstallationId: #{installationId}" unless !$verbose

        puts colored :default, "#{CHAR_VERBOSE} Getting access token" unless !$verbose

        # Request an access token
        uri = URI.parse("https://api.github.com/app/installations/#{installationId}/access_tokens")
        headers = {
            'Authorization': "Bearer #{jwtToken}",
        }

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        
        response = http.request(request)

        responseBody = JSON.load(response.body)
        accessToken = responseBody['token']
        expirationTime = Time.parse(responseBody['expires_at'])

        puts colored :default, "#{CHAR_VERBOSE} Retrieved access token: #{accessToken}" unless !$verbose

        Settings.update({
            'installation_access_token' => accessToken,
            'installation_access_token_expiration_time' => expirationTime.to_i,
        })

        puts colored :default, "#{CHAR_VERBOSE} Stored token and expiration date into storage" unless !$verbose

        return accessToken
    end
end