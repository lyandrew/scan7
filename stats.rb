require 'date'
require 'benchmark'
require 'oj'

class Stats
  def initialize(path_to_file)

    # Structure to use when collecting fastest/longest responses
    asset = Struct.new(:time, :asset, :ip)
    @fastest = asset.new(nil, nil, nil)
    @longest = asset.new(nil, nil, nil)

    @total_time = 0
    @count = 0
    @fastest_average = nil
    @fastest_key = nil
    @longest_average = nil
    @longest_key = nil
    @asset_hash = {}


    file = File.read(path_to_file)
    @json = Oj.load(file)
  end


  def process()

    # Iterate through each entries
    @json.each do |element|

      # Checks "start", "end", and invalid entries ("end" <= "start"). Skip these entries.
      if element["end"].empty? || element["start"].empty? || element["end"] <= element["start"]
        next
      end

      time_elapsed = DateTime.parse(element["end"]).to_time  - DateTime.parse(element["start"]).to_time

      @count += 1
      @total_time += time_elapsed

      # Keep track of fastest response
      if @fastest.time == nil or time_elapsed < @fastest.time
        @fastest.time = time_elapsed
        @fastest.asset = element["node_id"]
        @fastest.ip = element["ip"]
      end

      # Keep track of longest response
      if @longest.time == nil or time_elapsed > @longest.time
        @longest.time = time_elapsed
        @longest.asset = element["node_id"]
        @longest.ip = element["ip"]
      end

      # Keep track of each assest using a hashmap for average responses
      if @asset_hash.has_key?(element["ip"])
        @asset_hash[element["ip"]].push(time_elapsed)
      else
        # Create an array for the asset
        @asset_hash[element["ip"]] = [time_elapsed]
      end
    end

    # Iterate thru the hashmap, sum each assest's array to find the avereage time.
    @asset_hash.each do |key, array|
      sum = @asset_hash[key].inject(:+)
      size = @asset_hash[key].size
      ave_time = sum/size

      if @fastest_average == nil or ave_time < @fastest_average
        @fastest_key = key
        @fastest_average = ave_time
      end

      if @longest_average == nil or ave_time > @longest_average
        @longest_key = key
        @longest_average = ave_time
      end
    end
  end

  def print_stats
    puts "Average scan time: #{@total_time/@count} seconds"
    puts "Fastest scan: Asset: #{@fastest.asset} with #{@fastest.time} seconds"
    puts "Longest scan: Asset: #{@longest.asset} with #{@longest.time} seconds"
    puts "Fastest average scan: IP: #{@fastest_key} with #{@fastest_average} seconds"
    puts "Longest average scan IP: #{@longest_key} with #{@longest_average} seconds"
  end

end

time = Benchmark.measure {
  instance = Stats.new('scan-times.json')
  instance.process()
  instance.print_stats
}
puts "Ran in #{time.real.round(1)} seconds"
