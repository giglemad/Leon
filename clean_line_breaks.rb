load './utils.rb'

def clean_bad_line_breaks(raw_file, initial_file_path)
  f = File.open("cleaned_line_breaks_for_#{initial_file_path}","w+")

  # first line, col names
  raw_first_line = raw_file.gets
  raw_file_col_num = number_of_columns_from_line(raw_first_line)

  f.puts raw_first_line.chomp

  cleaned_lines = []

  raw_file.each do |raw_line|
    raw_line_col_num = number_of_columns_from_line(raw_line)
    raw_last_line_col_num = number_of_columns_from_line((cleaned_lines.last || []).join)
    line = raw_line.chomp.gsub(/\n/,'\\n')

    # Regular line, all fine
    if raw_file_col_num == raw_line_col_num
      cleaned_lines << [line]

    # Broken line but previous one was fine
    # If col num = 1, then no separator, means previous line missed this -> merge
    # Else, registers it, will try to complete it at next iteration
    elsif raw_last_line_col_num == raw_file_col_num
      if raw_line_col_num == 1
        cleaned_lines.last << '\n'
        cleaned_lines.last << line
      else
        cleaned_lines << [line]
      end

    # Broken line, Previous line broken
    # try to fix it by adding them if previous line col size + this one col
    # size is not too big, else FUCK IT
    elsif (raw_line_col_num + raw_last_line_col_num - 1) <= raw_file_col_num
      # Trying to merge 2 lines that could have been separated by a naughty \r\n
      cleaned_lines.last << '\n'
      cleaned_lines.last << line
    else
      raise "cannot repair CSV file for line #{line}"
    end
  end

  u = cleaned_lines.map do |line_array|
    line_array.join
  end


  u.each do |line|
    f.puts line
  end

  f
end
