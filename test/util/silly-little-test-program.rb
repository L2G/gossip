puts 'I am a silly little program.'
puts 'Here are my arguments:'
puts "   #{ARGV.join(' ')}"
puts "I mostly write to standard output."
$stdout.flush
$stderr.puts "I also write to standard error."
