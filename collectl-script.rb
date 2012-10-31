#!/usr/bin/ruby

#
# Collectl ruby script for output of aggregated disk IO performance
# Tested with Ruby 1.8+ and Ganglia 3.0.7
#

metricnames = ["CLKBRead", "CLReads", "CLKBWrit", "CLWrites"]
gmetric = "/usr/bin/gmetric"
collectlcommand = "collectl -sd"

def isnum(s)
  begin
    Float(s)
  rescue
    false # not numeric
  else
    true # numeric
  end
end

IO.popen(collectlcommand) do |output| 
  
  linenum = 0

  while line = output.gets do

    # Strip whitespace out 
    cleanedline = line.gsub(/ /,'')

    # Ingore any lines that are not numeric
    if isnum(cleanedline) == true

      # Split the string on spaces
      metricvalues = line.split(" ")

      if metricvalues.size() != metricnames.size()
        puts "Error in collectl output, abort"
	exit
      end
  
      4.times { |i|
        gmetricsend = `#{gmetric} -n #{metricnames[i]} -v #{metricvalues[i]} -t int16 -s positive -x 10`
      }
      
      cleanline = line.gsub(/\n/,'') 
      puts "GMetric: Sent #{cleanline}"

    end

  end
end
