require "option_parser"

class TapTempo
  @taps = Array(Time::Span).new
  @sample = 5
  @resetTime = 5
  @precision = 0

  def initialize
    generateHelp
  end

  def tap
    currentTap = Time.monotonic
    checkResetTime

    @taps.shift if @taps.size == @sample
    @taps << currentTap
  end

  def loop
    STDIN.raw &.each_char do |char|
      break if char == 'q'
      tap
      displayBPM
    end

    puts "Bye Bye!"
  end

  private def checkResetTime
    return if @taps.empty?
    @taps.clear if Time.monotonic - @taps[-1] > Time::Span.new(0, 0, @resetTime)
  end

  private def displayBPM
    if @taps.size == 1
      puts "[Hit a key one more time to start bpm computation...]\r"
      return
    end

    puts sprintf "Tempo: %." + normalizePrecision + "f bpm\r", getBPM
  end

  private def getBPM
    60.0 / ((@taps[-1] - @taps[0]) / (@taps.size.to_f - 1)).to_f
  end

  private def normalizePrecision
    return "" if @precision == 0
    @precision.to_s
  end

  private def generateHelp
    OptionParser.parse! do |parser|
      parser.banner = "Usage: #{PROGRAM_NAME} [options]"
      parser.on("-h", "--help", "display this help message") do
        puts parser
        exit
      end
      parser.on("-p", "--precision=#{@precision}", "set the decimal precision of the tempo display") { |precision| @precision = precision.to_i }
      parser.on("-r", "--reset-time=#{@resetTime}", "set the time in second to reset the computation") { |resetTime| @resetTime = resetTime.to_i }
      parser.on("-s", "--sample-size=#{@sample}", "set the number of samples needed to compute the tempo") { |sample| @sample = sample.to_i }
    end
  end
end

tapTempo = TapTempo.new
tapTempo.loop
