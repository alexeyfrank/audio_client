

def it(name)
  puts "----  #{name}"
  begin
    yield
  rescue Exception => e
    puts "!!!! TEST FAILED !!!!"
    puts e.message
    puts "\n"
  else
    puts "TEST COMPLETED\n"
  end
end

def should_be_equals(val, test_val)
  if val != test_val
    raise Exception.new "Exception: #{val} != #{test_val}"
  end
end


def assert (val)
  raise Exception.new "Exception: Get #{val}, expecting True" unless val
end
