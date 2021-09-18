# frozen_string_literal: true

$LOAD_PATH << './lib'
require 'fit'
require 'pathname'
require 'table_print'

DEBUG = false

def get_file_date(filename)
  res = nil

  begin
    fit_file = Fit.load_file(filename)
  rescue EOFError
    puts " ERROR: cannot load file #{filename}"
    return nil
  end

  records = fit_file.records.select { |r| r.content.record_type == :activity }.map(&:content)
  rec = records[0]
  timestamp = rec.send(:raw_timestamp).to_i
  if timestamp < 268435456
    offset = rec.send(:raw_local_timestamp).to_i
    res = Time.utc(1989, 12, 31, 0, 0, 0) + timestamp + offset
  end
  res
end

def get_move_to_do(filepath)
  res = nil
  path = Pathname.new(filepath)
  if DEBUG
    print "Checking date of #{path.basename}"
  else
    print '.'
  end
  offset = get_file_date(filepath)
  if offset
    res = /(_\d+_\d+\.fit)$/.match(filepath)
    str = format('%<year>04d-%<month>02d-%<day>02d_%<hour>02d-%<min>02d-%<sec>02d',
                 year: offset.year,
                 month: offset.month,
                 day: offset.day,
                 hour: offset.hour,
                 min: offset.min,
                 sec: offset.sec)
    new_name = str + res.to_s
    if path.basename.to_s != new_name
      res = "fossil mv #{path.basename} #{new_name}"
      puts " to be renamed to #{new_name}" if DEBUG
    elsif DEBUG
      puts ' OK'
    end
  elsif DEBUG
    puts ' OK'
  end
  res
end

move_to_do = []
ARGV.each do |arg|
  filepath = arg

  res = get_move_to_do(filepath)
  move_to_do << res unless res.nil?
end
puts
move_to_do.each do |str|
  puts str
end
# puts "File name = " + str + res.to_s
# puts "File Path = " + path.dirname.to_s + "/" + str + res.to_s
exit 0

# start_time = nil
# real_start_time = nil
#
# fit_file = Fit.load_file(filepaht, start_time, real_start_time)
#
# records = fit_file.records.reject { |r| r.content.record_type == :definition }.map(&:content)
# activity = records.select { |r| r.record_type == :activity }
#
# activity.each do |rec|
#   puts rec.record_type.inspect
#   puts rec.send(:raw_timestamp)
#   puts rec.send(:raw_local_timestamp)
# end

#   output[rec.record_type] ||= []
#   cur_output = {}
#   rec.snapshot.keys.each do |raw_key|
#     key = raw_key[4..-1].to_sym
#     cur_output[key] = rec.send(key)
#   end
#   output[rec.record_type] << cur_output
# end

# output.each do |type, content|
#   puts '###############################################################################'
#   puts type.to_s.capitalize
#   tp content
# end
