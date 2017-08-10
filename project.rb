require 'time'

def initialize_marshal
  tables = [Table.new(8,1), Table.new(4,2), Table.new(6,3), Table.new(2,4)]
  tables.sort_by!{|item| item.seats}
  marshal_file = [tables,[]]
  file = File.open("table_database", "w")
  Marshal.dump(marshal_file,file)
  file.close
end

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
    last_order_time = (queue.last && queue.last > Time.new) ? queue.last : Time.new
    ready_time = last_order_time + @cooking_time * @quantity * 60
    queue << ready_time
    write_db([read_db(0),queue])
    ready_time.strftime("%I:%M%p")
 end
end

def read_db(index)
  file = File.open("table_database", "r")
  read = Marshal.load(file)
  file.close
  return read[index]
end

def write_db(content)
  file = File.open("table_database", "w")
  Marshal.dump(content,file)
  file.close
end

def find_table(table_no,tables)
  tables.each {|table| return table if table.table_no == table_no}
end

def change_booking_status(table_no)
  tables = read_db(0)
  current_table = find_table(table_no,tables)
  current_table.booked = current_table.booked ? false : true
  puts current_table.booked
  write_db([tables,read_db(1)])
end

def add_order_to_table(table_no,order)
  tables = read_db(0)
  find_table(table_no,tables).order.push(order)
  write_db([tables,read_db(1)])
end

def display_menu(option,menu)
  option = :food if option == 1
  option = :drink if option == 2
  option = :dessert if option == 3
   menu[option].each_with_index do |name, index|
     name.each_key do |key|
       puts "#{index + 1}: #{key}"
     end
   end
  return option
end

def make_order(menu,table_no)
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
    print "Quantity: "
    qty = gets.chomp.to_i
    order = nil
    menu[option][order_select - 1].each do |key,value|
      order = Order.new(key,value[0],value[1],qty,read_db(1))
    end
    add_order_to_table(table_no,order)
    puts "#{order.order_name} x #{order.quantity}"
  end
end

def separator
 40.times {print "-"}
 puts "-"
end

initialize_marshal

menu = {
 food: [
   {pizza: [12,5]},
   {ravioli: [6,5]},
   {spaghetti: [7,5]}
 ],
 drink: [
   {coke: [2,1]}
   ],
 dessert: [
   {icecream: [3,1]}
 ]
}


puts "Welcome to Cafe De Lorenzo".center(40, "~")
print "How many people will be dining with us: "
guest_total = gets.chomp.to_i
table_no = nil

if guest_total > 8
   print "sorry"

elsif guest_total <= 8
  tables = read_db(0)
   tables.each do |table|
       if !table.booked && guest_total <= table.seats
         separator
           puts "You will be dining at Table Number #{table.table_no}"
           table_no = table.table_no
           change_booking_status(table_no)
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
     make_order(menu,table_no)
     find_table(table_no,read_db(0)).order.each do |order|
       puts "#{order.order_name} X #{order.quantity}"
     end

   elsif selection == 2
     find_table(table_no,read_db(0)).order.each do |order|
       puts "#{order.order_name} X #{order.quantity} Ready at:#{order.ready_time} $#{order.price * order.quantity}"
     end
      find_table(table_no,read_db(0)).count_total

   elsif selection == 3
     break
  end
 end
end
