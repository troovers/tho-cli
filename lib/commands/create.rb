require 'open-uri'
require 'json'
require 'yaml'
require 'tty-prompt'
require 'securerandom'

module Commands
    class Create

        def initialize(category, args)
            @@category = category
            @@args = {}

            enabledKeys = []

            if category == 'string'
                enabledKeys = ['length', 'symbols', 'digits', 'copy']
            elsif category == 'uuid'
                enabledKeys = ['copy']
            end

            @@args = args.select { |key, value| enabledKeys.include?(key) && !value.nil?  }

            @@prompt = TTY::Prompt.new
        end

        def execute

            if @@category == 'string'
                create_string
            elsif @@category == 'uuid'
                create_uuid
            end

        end

        def create_string
            config = Settings::get('strings', {})

            characters = %w{ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z }

            if @@args['digits'] != 'false' && (config['digits'] || @@args['digits'] == 'true' || false)
                characters.concat %w{ 1 2 3 4 5 6 7 8 9 0 }
            end

            if @@args['symbols'] != 'false' && (config['symbols'] || @@args['symbols'] == 'true' || false)
                characters.concat ["#", "[", "]", "{", "}", "/", "|", "!", "@", "$", "%", "^", "&", "*", "(", ")", "-", "_", "=", "+", ";", ":", "\\", ",", "<", ">", ".", "?"]
            end

            length = (@@args.key?('length') ? @@args['length'].to_i : nil) || config['length'] || 20

            string = (0...length).map{ characters.to_a[rand(characters.size)] }.join

            puts colored :green, "#{CHAR_CHECK} Your string: #{string}"

            _copy string
        end

        def create_uuid
            uuid = SecureRandom.uuid

            puts colored :green, "#{CHAR_CHECK} Your UUID: #{uuid}"

            _copy uuid
        end

        def _copy(value)
            if @@args['copy']
                copy_to_clipboard = true
            else
                copy_to_clipboard = @@prompt.yes?("Do you want me to copy it to your clipboard?") do |q|
                    q.default false
                end
            end

            if copy_to_clipboard
                `echo #{value} | pbcopy`

                puts colored :green, "#{CHAR_CHECK} Copied!"
            end
        end
    end
end
