def correct_split(line)
  puts 'nil line, will default to 0' if line.nil?
  silly_split = line.to_s.split(',', -1)
  fragments = []
  correct_split = []
  silly_split.each_with_index do |ck,index|
    if (fragments.size == 0)
      # column value has opening " but no ending "
      # column value has opening " and a double ending " -> special case
      # 'Really "superb", oki' translates as "Really ""superb"", oki" by
      # google csv export which messes up everything
      # Also must treat the case of value bing single commas or single "
      if (ck =~ /^".*[^"]$/) || (ck=~/^".*[^"]""$/)
        fragments << ck
      elsif (ck == '"') # Single comma delimited by quotation characters case
        fragments << '",'
      else
        correct_split << ck
      end
    else
      fragments << ck
      if (ck =~ /.*"$/) && !(ck =~ /[^"]""$/)
        correct_split << fragments.join(',')
        fragments.clear
      end
    end
  end

  correct_split
end

def number_of_columns_from_line(line)
  correct_split(line).size
end
