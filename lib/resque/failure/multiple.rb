module Resque
  module Failure
    # A Failure backend that uses multiple backends
    # delegates all queries to the first backend
    class Multiple < Base

      class << self
        attr_writer :classes

        def classes
          return @classes || []
        end
      end

      def self.configure
        yield self
        Resque::Failure.backend = self
      end

      def initialize(*args)
        super
        @backends = self.class.classes.map {|klass| klass.new(*args)}
      end

      def save
        @backends.each(&:save)
      end

      def self.with_first_class(default)
        return default unless classes.first

        yield classes.first
      end

      # The number of failures.
      def self.count(*args)
        with_first_class(0){|c| c.count(*args)}
      end

      # Returns a paginated array of failure objects.
      def self.all(*args)
        with_first_class([]){|c| c.all(*args)}
      end

      # Iterate across failed objects
      def self.each(*args, &block)
        with_first_class(nil){|c| c.each(*args, &block)}
      end

      # A URL where someone can go to view failures.
      def self.url
        with_first_class(nil){|c| c.url}
      end

      # Clear all failure objects
      def self.clear(*args)
        with_first_class(nil){|c| c.clear(*args)}
      end

      def self.requeue(*args)
        with_first_class(nil){|c| c.requeue(*args)}
      end

      def self.remove(index)
        classes.each { |klass| klass.remove(index) }
      end
    end
  end
end
