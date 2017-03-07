require 'stringio'
require 'blocks/block'

class ThreadOut

  def initialize(out)
    @out = out
  end

  def write(stuff='')
    if Thread.current[:stdout] then
      Thread.current[:stdout].write stuff
    else
      @out.write stuff
    end
  end

  def puts(stuff='')
    if Thread.current[:stdout] then
      Thread.current[:stdout].puts stuff
    else
      @out.puts stuff
    end
  end

  def print(stuff='')
    if Thread.current[:stdout] then
      Thread.current[:stdout].puts stuff
    else
      @out.print stuff
    end
  end

  def flush
    if Thread.current[:stdout] then
      Thread.current[:stdout].flush
    else
      @out.flush
    end
  end
end

STDOUT.sync = true
STDERR.sync = true
$stdout = ThreadOut.new(STDOUT)
$stderr = ThreadOut.new(STDERR)


class SyncOut
  def self.mutex
    @@mutex ||= Mutex.new
  end

  def self.flushOutput
    mutex.synchronize do
      tmp = Thread.current[:stdout]
      if tmp.string.length > 0
        Thread.current[:stdout] = Thread.current[:tmpStdout][Thread.current[:tmpStdout].length-1]
        puts tmp.string
        tmp.reopen("")
        Thread.current[:stdout] = tmp
      end
    end
  end

  def self.startStream
    s = StringIO.new
    if Thread.current[:tmpStdout].nil?
      Thread.current[:tmpStdout] = [Thread.current[:stdout]]
    else
      Thread.current[:tmpStdout] << Thread.current[:stdout]
    end

    Thread.current[:stdout] = s
  end

  def self.stopStream(result=true)
    s = Thread.current[:stdout]
    return if s.nil?
    Thread.current[:stdout] = Thread.current[:tmpStdout] ? Thread.current[:tmpStdout].pop : nil
    if s.string.length > 0
      mutex.synchronize do
        if !result && Bake.options.stopOnFirstError
          Thread.current[:errorStream] << s.string
        else
          if Bake.options.syncedOutput
            if s.string.gsub!(">>CONF_NUM<<", Bake::Blocks::Block.block_counter.to_s)
              Bake::Blocks::Block.inc_block_counter
            end
          end
          puts s.string
        end
      end
      s.reopen("")
    end
  end


  def self.discardStreams()
    Thread.current[:tmpStdout] = []
  end

  def self.flush_errors
    if !Thread.current[:errorStream].empty?
      if Bake.options.syncedOutput
        if Thread.current[:errorStream].gsub!(">>CONF_NUM<<", Bake::Blocks::Block.block_counter.to_s)
          Bake::Blocks::Block.inc_block_counter
        end
      end
      puts Thread.current[:errorStream]
      reset_errors
    end
  end

  def self.reset_errors
    Thread.current[:errorStream] = ""
  end

end

