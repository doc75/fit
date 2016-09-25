$LOAD_PATH << './lib'
require 'fit'
require 'pathname'
require 'table_print'

offset = { '1990-01-08_14-52-13_4_11.fit' => [738748, 789127828],
           '1990-01-10_15-22-46_4_13.fit' => [913451, 789302531],
           '2016-09-25_09-18-00_4_15.fit' => [1802565, 843722280],
           '2016-09-20_12-31-00_4_13.fit' => [1382103, 843301860], 
           '2016-09-15_12-45-00_4_11.fit' => [950957, 842870700] }

filepath = ARGV[0]
filename = Pathname.new(filepath).basename

start_time = nil
real_start_time = nil

if offset.has_key? filename.to_s
  start_time = offset[filename.to_s][0]
  real_start_time = offset[filename.to_s][1]
end

fit_file = Fit.load_file(ARGV[0], start_time, real_start_time)

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

