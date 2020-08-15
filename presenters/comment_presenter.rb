class CommentPresenter
    def self.commit_message_of(comment)
      "comment: %{user} on %{post}" % { user: comment.name, post: comment.post }
    end
end
