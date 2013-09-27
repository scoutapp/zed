$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'
require 'webrick'
require 'erb'
require 'logger'
require 'json'

require 'zed/version'
require 'zed/collector'
require 'zed/web_server'

Thread.abort_on_exception=true

module Zed
  @@logger=nil
  def self.logger;@@logger;end
  def self.logger=(l)@@logger=(l);end
  class Main
    INTERVAL=1
    LOG_NAME="log.txt"

    attr_accessor :running, :collector, :stats_thread

    def initialize(opts={})
      home_dir_path = File.expand_path("~/zed")
      if opts[:stdout]
        puts " ** Initializing. cntl-c to stop. Logging to STDOUT **"
        Zed::logger=Logger.new(STDOUT)
      else
        puts " ** Initializing. cntl-c to stop. See logs in #{home_dir_path}/ **"
        Zed::logger=Logger.new(File.join(home_dir_path,LOG_NAME))
      end

      @home_dir = File.exist?(home_dir_path) ? File.new(home_dir_path) : Dir.mkdir(home_dir_path)
      @stats_thread = Thread.new {}
      @collector = Zed::Collector.new
    end

    def start_thread
      return if @running
      logger.info("starting stats collector thread")
      @running = true
      @stats_thread = Thread.new do
        while (@running) do
          @collector.run
          logger.info("collector thread run ##{@collector.num_runs} ") if @collector.num_runs.to_f % 50.0 == 0 || @collector.num_runs == 1
          sleep INTERVAL
        end
      end

    end

    def stop_thread!
      logger.info("stopping collector thread")
      @running=false
    end

    def go
      logger.info ("starting web server ")
      server = WEBrick::HTTPServer.new(:Port => 5555,:AccessLog=>[])
      server.mount '/', Zed::WebServer
      trap 'INT' do
        server.shutdown
      end
      start_thread
      server.start # blocking
    end

    # singleton
    def self.instance(opts={})
      @@instance ||= self.new(opts)
    end

    def logger
      Zed::logger
    end
  end
end
