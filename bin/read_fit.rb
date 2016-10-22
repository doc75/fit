$LOAD_PATH << './lib'
require 'fit'
require 'pathname'
require 'table_print'

def get_offset(filename)
  offset = nil

  fit_file = Fit.load_file(filename)

  records = fit_file.records.select{ |r| r.content.record_type == :activity }.map{ |r| r.content }
  rec = records[0]
  local_ts = rec.send(:raw_timestamp).to_i
  if local_ts < "0x10000000".hex
    offset = rec.send(:raw_local_timestamp).to_i
  end
 
  offset
end

filepath = ARGV[0]

offset = get_offset(filepath)

fit_file = Fit.load_file(filepath, offset)

records = fit_file.records.select{ |r| r.content.record_type != :definition }.map{ |r| r.content }
output = {}
records.each do |rec|
  output[rec.record_type] ||= []
  cur_output = {}
  rec.snapshot.keys.each do |raw_key|
    key = raw_key[4..-1].to_sym
    cur_output[key] = rec.send(key)
  end
  output[rec.record_type] << cur_output
end

output.each do |type, content|
  puts '###############################################################################'
  puts type.to_s.capitalize
  tp content
end

