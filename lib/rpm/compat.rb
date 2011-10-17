require 'rpm'

module RPM

  # compatibility
  Tag.to_h.each do |k,v|
    const_set "TAG_#{k.to_s.upcase}", v.to_i
  end

  LogLevel.to_h.each do |k, v|
  	const_set "LOG_#{k.to_s.upcase}", v.to_i
  end

end
