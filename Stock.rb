class Stock
  attr_accessor :date ; 
  attr_accessor :begin_price  , :end_price , :max_price , :min_price  ;
  attr_accessor :trade_amount , :trade_price ;

  def to_list()
    [date , begin_price , max_price , end_price , min_price , trade_amount , trade_price ]
  end
end

# s = Stock.new
# s.date =  "12010" ;
# print s.date
# s.begin_price = 10000
# print s.begin_price
