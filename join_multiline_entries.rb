def join_multilines_csv_entries(raw_file)
  f = File.open("joined_multilines_csv_entries_for_#{raw_file.path}","w+")

  # first line is columns and second line is garbage
  f << raw_file.gets
  raw_file.gets

  lines_to_join = []

  raw_file.each do |line|
    if has_end_line_separator(line)
      lines_to_join << line
      f.puts join_lines(lines_to_join)

      lines_to_join.clear
    else
      lines_to_join << line
    end
  end

  f
end

def has_end_line_separator(line)
  line =~ /\r\n/
end

def join_lines(lines)
  # XXX could induce in errors since we rely on f.puts in other method to
  # add line separator back
  lines.join.sub(/\r\n/,'').split(/\n/).join("\\n")
end
