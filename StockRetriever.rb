# -*- coding: gb2312 -*-
require "open-uri"
require 'csv'
require 'nkf'

require './Stock.rb'

class StockRetriever
  
  def initialize( code )
    @code = code
    @address = "http://money.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/" + @code + ".phtml"
    
    @yearstart = false
    @years = Array.new
    @stocks = Array.new
  end

  def retrieve( )
    
    # Get the years 
    file = open( @address )do |file|
      while line = file.gets
        
        # get the name
        if line.match("<select\ name=\"year\">" )  then
          @yearstart = true 
        end

        if line.match("<option\ value=.*?</option>") then
          if @yearstart
            year = /<option\ value=.*?>(\d{4})<\/option>/.match( line )
            @years.insert( 0 , year[1] )
          end
        end

        if line.match("</select>") then 
          @yearstart = false 
        end
      end
    end

    # put the years
    # for year in @years
    #   puts year
    # end

    # request all the data
    for year in @years
      for i in ["1" , "2" , "3" , "4"]
        url = @address + "?year=" + year + "&jidu=" + i
        puts url

        s = nil
        index = -1
        tempStocks = Array.new 
        
        file = open( url ) do | file |
          while line = file.gets
            #  parse the date without the link 
            if  /[\d]{4}-[\d]{2}-[\d]{2}.*<\/div><\/td>/.match( line )  then
              s = Stock.new
              s.date = /[\d]{4}-[\d]{2}-[\d]{2}/.match( line )
              index = 0 
            end
            
            # parse the data with a link
            if  /[\d]{4}-[\d]{2}-[\d]{2}.*<\/a>/.match( line )  then
              s = Stock.new
              s.date = /[\d]{4}-[\d]{2}-[\d]{2}/.match( line )
              index = 0 
            end
            
            if data = /<div\ align="center">([\d\.]*)<\/div><\/td>/.match( line ) then
              case index
              when 0
                s.begin_price = data[1]
              when 1
                s.max_price = data[1]
              when 2
                s.end_price = data[1]
              when 3
                s.min_price = data[1]
              when 4
                s.trade_amount = data[1]
              when 5 
                s.trade_price = data[1]
                tempStocks.insert( 0 ,  s )
                
                #reset the variable
                s = nil
                index = -1
              end
              index = index + 1 
            end
          end
        end
        for stock in tempStocks
          @stocks.push( stock )
        end
      end
    end
  end

  def stocks()
    @stocks
  end  
end

def outputArrayToCSV( path , header , data )

  # generate the csv buffer 
  output = CSV.generate do |csv|
    csv << header 
    for stock in data
      csv << stock.to_list
    end
  end

  #wirte to a file 
  fh = File.new( path  , "wb")
  fh.puts NKF.nkf("-wl" , output  )
  fh.close 

end

stockRetriver = StockRetriever.new( "300344")
stockRetriver.retrieve()

puts stockRetriver.stocks.size 
header = ["date" , "begin_price" , "max_price" , "end_price" , "min_price" , "trade_amount" , "trade_price" ]
outputArrayToCSV("sz300344.csv" , header , stockRetriver.stocks )

# file_name = ["date" , "begin_price" , "max_price" , "end_price" , "min_price" , "trade_amount" , "trade_price" ] 
# output = CSV.generate do |csv|
#   csv << file_name
#   for stock in stockRetriver.stoc
#     csv << stock.to_list
#   end
# end

# fh = File.new("test.csv" , "wb")
# fh.puts NKF.nkf("-wl" , output  )
# fh.close 
