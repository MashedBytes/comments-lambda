require_relative "comment"

class Comments
    attr_accessor :comments
    
    def initialize(raw_comments)
        @comments = {}
        raw_comments.each do |post, raw_comments|
            @comments[post] = {}
            raw_comments.each do |id, raw_comment|
                @comments[post][id] = Comment.new(**raw_comment)
             end
        end
    end

    def << (comment)
        @comment = comment
        if @comment.is_a_reply?
            raise ArgumentError, "No comment found with id #{@comment.parent_id} in #{@comment.post}" if parent_comment.nil?
            parent_comment.replies << @comment 
        else
            post_comments[@comment.id] = @comment
        end
    end

    def as_json
        comments.each_with_object({}) do |(post, post_comments), hash|
            hash[post] = {}
            post_comments.each do |id, comment|
                hash[post][id] = comment.as_json
            end
        end
    end

    private

    def post_comments
        comments[@comment.post] ||= {}
    end

    def parent_comment
        post_comments[@comment.parent_id]
    end
end