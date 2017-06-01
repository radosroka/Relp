require 'socket'
require 'date'

client = TCPSocket.new 'localhost', 5000

client.puts "Hello !"
client.puts "Time is #{Time.now}"
client.puts "Date is #{Date.today}"

client.close             # close socket if done