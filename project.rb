require 'time'
class Table
   attr_reader :seats, :booked, :table_no, :total
   attr_accessor :order, :booked
 def initialize(seats, table_no)
   @seats = seats
   @table_no = table_no
   @booked = false
   @order = []
 end
 def count_total
    total = 0
      @order.each do |order|
      total += order.total
    end
    puts "Total: $#{total}"
 end
end
class Customer
 def initialize(name)
   @name = name
 end
end
class Order
 attr_accessor :order_name, :quantity, :order_time, :price, :total, :ready_time
 def initialize(order_name, price, cooking_time, quantity,queue)
   @order_name = order_name
   @cooking_time =  cooking_time
   @quantity = quantity
   @order_time = Time.new
   @price = price
   @total = @price * @quantity
   @ready_time = count_ready_time(queue)
 end
 def count_ready_time(queue)
    last_order_time = queue.last ? queue.last : Time.new
   time = last_order_time + @cooking_time * @quantity * 60
   queue << time
   time.strftime("%I:%M%p")
 end
end
menu = {
 food: [
   {pizza: [12,5]},
   {ravioli: [6,5]},
   {spaghetti: [7,5]}
 ],
 drink: [{
   coke: [2,1]
 }],
 dessert: [{
   icecream: [3,1]
 }]
}
table1, table2, table3, table4 = [Table.new(8,1), Table.new(4,2), Table.new(6,3), Table.new(2,4)]
tables = [table1, table2, table3,table4]
tables.sort_by!{|item| item.seats}
puts "Welcome to Cafe De Lorenzo".center(40, "~")
print "How many people will be dining with us: "
guest_total = gets.chomp.to_i
def separator
 40.times {print "-"}
 puts "-"
end
def find_table(tables,table_no)
  tables.each {|table| return table if table.table_no == table_no}
end
def display_menu(option,menu)
option = :food if option == 1
option = :drink if option == 2
option = :dessert if option == 3
   menu[option].each_with_index do |name, index|
     name.each_key do |key|
       puts "#{index + 1}: #{key}"
     end
#    puts "#{index + 1}: #{name[0]}"
   end
return option
end
def make_order(menu,tables,table_no,queue)
  loop do
  puts "1: Food"
  puts "2: Drinks"
  puts "3: Dessert"
  puts "4: Finish"
  separator
  print "Selection: "
  selection = gets.chomp.to_i
  break if selection == 4
  option = display_menu(selection, menu)
  separator
  print "Selection: "
  order_select = gets.chomp.to_i
  order = nil
  print "Quantity: "
  qty = gets.chomp.to_i
  menu[option][order_select - 1].each do |key,value|
    order = Order.new(key,value[0],value[1],qty,queue)
  end
  puts "#{order.order_name} x #{order.quantity}"
  find_table(tables,table_no).order.push(order)
end
end

queue = []
table_no = nil
if guest_total > 8
   print "sorry"
elsif guest_total <= 8
   tables.each do |table|
       if !table.booked && guest_total <= table.seats
         40.times {print "-"}
         puts "-"
           puts "You will be dining at Table Number #{table.table_no}"
           table_no = table.table_no
           find_table(tables,table_no).booked = true
           break
       end
   end
   separator
   loop do
   puts "1: Menu"
   puts "2: Order"
   puts "3: Exit"
   separator
   print "Selection: "
   selection = gets.chomp.to_i
   separator
   if selection == 1
     make_order(menu,tables,table_no,queue)
     find_table(tables,table_no).order.each do |order|
       puts "#{order.order_name} X #{order.quantity}"
     end
   elsif selection == 2
     find_table(tables,table_no).order.each do |order|
       puts "#{order.order_name} X #{order.quantity} Ready at:#{order.ready_time} $#{order.price * order.quantity}"
     end
      find_table(tables,table_no).count_total
   elsif selection == 3
     break
  end
 end
end
