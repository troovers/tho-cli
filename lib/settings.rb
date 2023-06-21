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

        structure = key.split '.'

        value = @@config

        structure.each do |key|
            if value[key] == nil
                return default
            end

            value = value[key]
        end

        return value
    end

    def self.write(key, value)
        refresh

        structure = key.split '.'

        path = @@config

        structure.each do |key|
            if path[key] == nil
                path[key] = {}
            end

            path = path[key]
        end

        path = value

        puts structure
        
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