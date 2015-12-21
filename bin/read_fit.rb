$LOAD_PATH << './lib'
require 'fit'
require 'table_print'

fit_file = Fit.load_file(ARGV[0])

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

