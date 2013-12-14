require "open-uri"
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
                s.begin_price = data
              when 1
                s.max_price = data
              when 2
                s.end_price = data
              when 3
                s.min_price = data
              when 4
                s.trade_amount = data
              when 5 
                s.trade_price = data
                
                #reset the variable
                s = nil
                index = -1
              end
              index = index + 1 
            end
            
          end
        end
      end
    end
    
  end
end

stockRetriver = StockRetriever.new( "600000")
stockRetriver.retrieve()
