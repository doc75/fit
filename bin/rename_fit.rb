$LOAD_PATH << './lib'
require 'fit'
require 'pathname'
require 'table_print'


def get_file_date(filename)
  offset = nil

  fit_file = Fit.load_file(filename)

  records = fit_file.records.select{ |r| r.content.record_type == :activity }.map{ |r| r.content }
  rec = records[0]
  timestamp = rec.send(:raw_timestamp).to_i
  if timestamp < "0x10000000".hex
    offset = rec.send(:raw_local_timestamp).to_i
    Time.utc(1989,12,31,0,0,0) + timestamp + offset
  else
    #res = Time.utc(1989,12,31,0,0,0) + timestamp
    #res.localtime
    # No need to rename
    nil
  end
end

ARGV.each do |arg|
  filepath = arg
  path = Pathname.new(filepath)

  offset = get_file_date(filepath)
  if offset
    res = /(_\d+_\d+\.fit)$/.match(filepath)
    str = "%04d-%02d-%02d_%02d-%02d-%02d" % [ offset.year, offset.month, offset.day, offset.hour, offset.min, offset.sec ]
    new_name = str + res.to_s
    if path.basename.to_s != new_name
     puts "git mv #{path.basename.to_s} #{new_name}"
    end
  end
end
#puts "File name = " + str + res.to_s
#puts "File Path = " + path.dirname.to_s + "/" + str + res.to_s
exit 0


start_time = nil
real_start_time = nil

fit_file = Fit.load_file(filepaht, start_time, real_start_time)

records = fit_file.records.select{ |r| r.content.record_type != :definition }.map{ |r| r.content }
activity = records.select { |r| r.record_type == :activity }

  output = {}
activity.each do |rec|
  puts rec.record_type.inspect
  puts rec.send(:raw_timestamp)
  puts rec.send(:raw_local_timestamp)
end


#  output[rec.record_type] ||= []
#  cur_output = {}
#  rec.snapshot.keys.each do |raw_key|
#    key = raw_key[4..-1].to_sym
#    cur_output[key] = rec.send(key)
#  end
#  output[rec.record_type] << cur_output
#end

#output.each do |type, content|
#  puts '###############################################################################'
#  puts type.to_s.capitalize
#  tp content
#end

