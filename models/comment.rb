require "uuidtools"
require "active_support/core_ext/hash/indifferent_access"


class Comment
    REQUIRED_ATTRIBUTES = [:post, :name, :comment, :timestamp]
    ALLOWED_ATTRIBUTES = REQUIRED_ATTRIBUTES + [:id, :email, :replies, :parent_id]
    attr_accessor *ALLOWED_ATTRIBUTES

    def initialize(**kwargs)
        kwargs = kwargs.deep_symbolize_keys

        missing_attributes = REQUIRED_ATTRIBUTES - kwargs.keys.map(&:to_sym)
        if missing_attributes.size > 0
            raise ArgumentError, "Missing required attributes: #{missing_attributes.join(" ")}"
        end

        kwargs.slice(*ALLOWED_ATTRIBUTES).each do |key, value|
            if key == :replies
                @replies = value.map { |value| Comment.new(value) }
            else
                instance_variable_set("@#{key}", value)
            end
        end

        @replies = [] if replies.nil?
        @id = generated_id if id.nil?
    end

    def is_a_reply?
        !parent_id.nil?
    end

    def generated_id
        UUIDTools::UUID.random_create.to_s
    end

    def as_json
        instance_variables.each_with_object({}) do |var, hash|
            key = var.to_s[1..-1]
            value = instance_variable_get(var)

            if value.is_a? Array
                hash[key] = value.map(&:as_json)
            else
                hash[key] = value
            end

        end
    end
end