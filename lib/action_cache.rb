module ActionController
  module Caching
    module Actions
      class ActionCachePath
        # allow caching that takes into account url parameters
        def initialize(controller, options = {}, infer_extension = true)
          path = controller.request.url.split('://',2).last
          normalize!(path)
          @path = URI.unescape(path)
        end
      end
    end
  end
end

module ActiveSupport
  module Cache
    # A cache store implementation which stores everything on the filesystem.
    class FileStore
      # http://github.com/rails/rails/commit/b5775c2b3efb3ae5ef9074d26f6fc3e302a4f6f0
      def read(name, options = nil)
        super

        file_name = real_file_path(name)
        expires = expires_in(options)

        if File.exist?(file_name) && (expires <= 0 || Time.now - File.mtime(file_name) < expires)
          File.open(file_name, 'rb') { |f| Marshal.load(f) }
        end
      end
    end
  end
end
