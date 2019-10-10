$LOAD_PATH << './lib'
require 'fit'
require 'pathname'
require 'table_print'

#filter_message = [:session]
#filter_field = { :session => [:length_count] }
#filter_field = { :session => [:start_time, :total_elapsed_time, :total_distance, :total_cycles, :avg_speed, :max_speed, :num_laps, :length_count, :pool_length, :total_swim_time, :average_stroke, :swolf, :avg_cadence, :max_cadence] }
filter_message = []
filter_field = {}

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

ARGV.each do |arg|
  filepath = arg

  offset = get_offset(filepath)

  fit_file = Fit.load_file(filepath, offset)

  records = fit_file.records.select{ |r| r.content.record_type != :definition }.map{ |r| r.content }
  output = {}
  records.each do |rec|
    type = rec.record_type
    if filter_message.empty? or filter_message.include?(type)
      output[type] ||= []
      cur_output = {}
      rec.snapshot.keys.each do |raw_key|
        key = raw_key[4..-1].to_sym
        if filter_field.empty? or filter_field[type].include?(key)
          cur_output[key] = rec.send(key)
        end
      end
      if cur_output[:length_count].to_i == 0
        output[type] << cur_output
      else
        output.except!(type)
      end
    end
  end

  puts "#{filepath}"
  if !output.empty?
  output.each do |type, content|
    puts '###############################################################################'
    puts type.to_s.capitalize
    tp content
  end
  end
end

