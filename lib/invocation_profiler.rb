require "invocation_profiler/version"

module InvocationProfiler

  module Aggregated
    def self.included(mod)
      mod.extend ClassMethode
      mod.class_eval do
        cattr_accessor :stats
        @@traced_methods = {}
        self.stats ||= {}

        traced_methods = defined?(TRACED_METHODS) && TRACED_METHODS || self.instance_methods(false)
        untraced_methods = defined?(UNTRACED_METHODS) && UNTRACED_METHODS || []
        traced_methods.each do |meth|
          #puts "instance method #{meth}"
          #next if meth.to_s.start_with?('_unmemoized_') ||
          next if meth.to_s.start_with?('_untraced_')
          next if untraced_methods.is_a?(Regexp) && meth.to_s =~ untraced_methods
          next if untraced_methods.is_a?(Array) && untraced_methods.include?(meth)

          next if @@traced_methods[meth.to_s]
          @@traced_methods[meth.to_s] = true

          #puts "instance method #{meth}"
          alias :"_untraced_#{meth}" :"#{meth}"

          define_method meth do |*args|
            result = nil
            realtime = Benchmark.realtime do
              result = send(:"_untraced_#{meth}", *args)
            end

            self.class.stats[meth] ||= { count: 0, time: 0.0, times: [] }
            self.class.stats[meth][:count] +=1
            self.class.stats[meth][:time] += realtime
            self.class.stats[meth][:times] << realtime

            result
          end
        end
      end
    end

    module ClassMethode
      def gather_times
        out = ""
        sample_times = self.const_defined?(:SAMPLE_TIMES) && self.const_get(:SAMPLE_TIMES) || 3
        stats = self.stats.to_a
        self.stats = {}
        stats.sort! { |a, b| a.last[:time] <=> b.last[:time] }
        out << "-" * 30 + " " + Time.now.to_s + "\n"
        total_time = 0.0
        total_count = 0
        stats.each do |stat|
          method = stat.first
          mstats = stat.last
          total_time += mstats[:time]
          total_count += mstats[:count]
          times = mstats[:times].sort { |a, b| b <=> a }
          out << "#{method}, time: %0.3f, count: #{mstats[:count]}, times: %s\n" % [mstats[:time], times.collect { |t| "%0.3f" % t }[0..sample_times]]
        end
        out << "-=" * 15 + "\n"
        out << "TOTAL: #{total_time} in #{total_count} invocations\n"
        out
      end

      def write_times(file_name)
        File.open(file_name, "w+") { |f| f.write(gather_times) }
      end
    end
  end
end
