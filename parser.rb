# Kannada is used as a sample CSV. Stick to it. It should work otherwise but consistency is key.
# Parse CSV files and convert them to JSON.


# Usage: ruby ./parser.rb /path/to/input.csv /path/to/chakrafile.txt /path/to/output.json
# Example: ruby ./parser.rb csv/kannada/kannada.csv csv/kannada/kannada.txt json/kannada.json


# Don't forget to remove the additional backlashes present in the JSON generated.
# TODO : It's a bug

require 'rubygems'
require 'json'
require 'csv'

# Get in the following fields from the csv
# code - int - DONE
# label - unicode - DONE
# showchakra - bool - DONE
# showcustomChakra - DONE
# customchakralayout - DONE
# showicon - bool
# icon - "" - Check what comes in exceptions here - Gujrati, Konkani, Marathi
# changeLayout - bool
# layout - "" - Check in the exeptions

# opens the CSV file
lines = CSV.open(ARGV[0]).readlines

# The JSON Keys as per the Android Application
keys = [
  "code", "label", "showchakra",
  "showcustomchakra", "customchakralayout", "showicon",
  "icon", "changelayout", "layout"
]

#Defines the JSON structure
data = {
  :name => ARGV[0],
  :defaultchakra => [],
  :csv => []
}

# opens the chakra file
# TODO - fix character escaping.

File.open(ARGV[1], "r") do |i|
  i.each_line do |chakra|
    data[:defaultchakra] = chakra
  end
  i.close
end


File.open(ARGV[2], "w") do |f|
  data[:csv] = lines.map do |values|
    Hash[keys.zip(values)]
  end
  csv = data[:csv]
  csv.each do |row|

    # Chakra Properties
    if row["showchakra"] == "1"
      # Case 1 - Chakra present, Custom Chakra absent.
      row["showchakra"] = true
      row["showcustomchakra"] = false
      row["customchakralayout"] = []
    elsif row["showchakra"] == "0"
      # Case 2 - No chakra and no custom chakra
      row["showchakra"] = false
      row["showcustomchakra"] = false
      row["customchakralayout"] = []
    else
      # Case 3 chakra present but custom chakra also present.
      row["customchakralayout"] = row["showchakra"].split(" ")
      row["showchakra"] = true
      row["showcustomchakra"] = true
    end

    # Icon Properties - Untouched for corner cases
    row["showicon"] = false
    row["icon"] = ""

    #Layout - Untouched for corner cases.
    row["changelayout"] = false
    row["layout"] = ""
  end
  data = JSON.pretty_generate(data)
  f.puts data
end
