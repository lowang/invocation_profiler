# InvocationProfiler

Poor's man profiling on class method invocations.
When you can't make sense of output from "JRuby::Profiler.profile do"
install InvocationProfiler to obtain profiling results like:

    ------------------------------ 2014-08-28 10:51:18 +0200
    suspected_method, time: 0.009, count: 3, times: ["0.003", "0.003", "0.003"]
    -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    TOTAL: 0.008 in 3 invocations

It works by wrapping original method with Benchmark.realtime and aggregating all instances invocations times,
so:

    3.times { A.new.suspected_method }

would count total 3 invocations in the A class

## Installation

Add this line to your application's Gemfile:

    gem 'invocation_profiler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install invocation_profiler

## Usage

just attach this module at the end of the suspected class

    class A
      def suspected_method
        ...
      end
      include ::InvocationProfiler::Aggregated
    end

and print put the results, for controller it will be after render method, eg.:

    def index
      ...
      render json: @response
      puts ::A.gather_times
    end

or just save them to a file:

    def index
      ...
      render json: @response
      ::A.write_times(Rails.root.join('tmp/class_a.profile'))
    end

additional options are passed as Class constants:

    class A
      ...
      UNTRACED_METHODS = /^_unmemoized_/
      # or as an Array:
      #UNTRACED_METHODS = ['_unmemoized_suspected_method1',...]
      SAMPLE_TIMES = 7
      include ::InvocationProfiler::Aggregated
    end

## Contributing

1. Fork it ( https://github.com/lowang/invocation_profiler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
