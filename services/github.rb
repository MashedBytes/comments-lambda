require "octokit"
require "yaml"

require_relative "../models/comments"

class Github
    attr_accessor :ref, :repo, :comments_file_path
    attr_reader :client

    def initialize(access_token:, ref:, repo:, comments_file_path:)
        @client = Octokit::Client.new(access_token: access_token)
        @ref = "heads/#{ ref || 'master' }"
        @repo = repo
        @comments_file_path = comments_file_path
    end

    def comments
        @comments ||= Comments.new begin
            comments_file = client.contents(repo, path: comments_file_path, query: { ref: ref })
            comments_file = Base64.decode64(comments_file.content)
            YAML.load(comments_file)
        rescue Octokit::NotFound
            {}
        end
    end

    def push_changes(commit_message:)
        content = YAML.dump(comments.as_json)
        content = Base64.encode64(content)
      
        sha_latest_commit = client.ref(repo, ref).object.sha
        sha_base_tree = client.commit(repo, sha_latest_commit).commit.tree.sha
        blob_sha = client.create_blob(repo, content, "base64")
        sha_new_tree = client.create_tree(repo,
                                          [{ :path => comments_file_path,
                                             :mode => "100644",
                                             :type => "blob",
                                             :sha => blob_sha }],
                                          { :base_tree => sha_base_tree }).sha
        sha_new_commit = client.create_commit(repo, commit_message, sha_new_tree, sha_latest_commit).sha
        client.update_ref(repo, ref, sha_new_commit)
    end
end
