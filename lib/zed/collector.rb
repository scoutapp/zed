require 'scout/plugin'
require 'scout/cpu_usage'
require 'scout/memory_profiler'
require 'scout/disk_usage'
require 'scout/iostat'


module Zed
  class Collector
    attr_accessor :num_runs
    attr_accessor :latest_run

    def initialize
      @latest_run = {}
      @num_runs=0
      @plugins={MemoryProfiler=>[nil,{},{}], DiskUsage=>[nil,{},{}]}
      if RUBY_PLATFORM.include?("linux")
        @plugins.merge!(Iostat=>[nil,{},{}],CpuUsage=>[nil,{},{}])
      end
      @hostname = Socket.gethostname
    end

    def run
      plugin_outputs=[]
      @plugins.each_pair do |klass,args|
        plugin=klass.new(*args)
        start_time=Time.now
        res=plugin.run
        duration=((Time.now-start_time)*1000).to_i
        @plugins[klass]=[Time.now, args[1], res[:memory]] # saves for next time ... need a clearer approach for this

        plugin_outputs << { :duration=>duration,
                            :fields=>plugin.reports.inject{|memo,hash|memo.merge(hash)},
                            :class=>klass.name }

      end

      latest_run ={ :hostname=> @hostname,
                    :server_time=>Time.now.strftime("%I:%M:%S %p"),
                    :server_unixtime => Time.now.to_i,
                    :num_processes=>`ps -e | wc -l`.chomp.to_i,
                    :plugins=>plugin_outputs }

      @latest_run=latest_run
      @num_runs +=1
    end
  end
end