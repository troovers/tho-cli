class Settings
    @@config = nil
    @@configDirectory = "#{Dir.home}/.tho"

    def self.refresh
        Dir.mkdir @@configDirectory unless File.exist? @@configDirectory

        unless File.exist? "#{@@configDirectory}/config.yaml"
            FileUtils.touch("#{@@configDirectory}/config.yaml")
        end

        @@config = YAML.load_file("#{@@configDirectory}/config.yaml") || {}
    end

    def self.load
        unless @@config != nil
            refresh
        end
    end

    def self.get(key, default=nil)
        load

        if @@config[key] == nil
            return default
        end

        return @@config[key]
    end

    def self.write(key, value)
        refresh

        @@config[key] = value
        
        File.write("#{@@configDirectory}/config.yaml", @@config.to_yaml)
    end

    def self.update(hash)
        raise TypeError, 'parameter has to be a hash' unless hash.is_a?(Hash)

        refresh
        
        @@config = @@config.merge(hash)

        File.write("#{@@configDirectory}/config.yaml", @@config.to_yaml)
    end

    def self.all
        load

        return @@config
    end
end