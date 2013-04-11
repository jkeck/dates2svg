require "spec_helper"
require "dates2svg"

class DateValue
  attr_reader :value, :hits
  def initialize(ops={})
    @value = ops[:value]
    @hits = ops[:hits]
  end
end

describe Dates2SVG do
  before(:all) do
    @hits_values = [98, 401, 500, 400, 100]
    @dates = [
    DateValue.new(:value=>"1779-05-02", :hits =>6),
    
    DateValue.new(:value=>"1789-01-05", :hits =>8),
    DateValue.new(:value=>"1789-01-11", :hits =>20),
    DateValue.new(:value=>"1789-01-12", :hits =>10),
    
    DateValue.new(:value=>"1789-03-10", :hits =>50),
    DateValue.new(:value=>"1789-03-15", :hits =>100),
    DateValue.new(:value=>"1789-03-20", :hits =>400),
    DateValue.new(:value=>"1789-03-20", :hits =>323),
    DateValue.new(:value=>"1789-03-14", :hits =>122),
    DateValue.new(:value=>"1789-03-29", :hits =>426),
    
    DateValue.new(:value=>"1789-01-12", :hits =>10),
    
    DateValue.new(:value=>"1789-06-30", :hits =>5),
    
    DateValue.new(:value=>"1789-07-01", :hits =>7),
    DateValue.new(:value=>"1789-07-02", :hits =>4),
    DateValue.new(:value=>"1789-07-03", :hits =>5),
    DateValue.new(:value=>"1789-07-04", :hits =>7),
    DateValue.new(:value=>"1789-07-06", :hits =>6),
    
    DateValue.new(:value=>"1790-06-30", :hits =>40),
    
    DateValue.new(:value=>"1790-07-01", :hits =>@hits_values[0]),
    DateValue.new(:value=>"1790-07-02", :hits =>@hits_values[1]),
    DateValue.new(:value=>"1790-07-03", :hits =>@hits_values[2]),
    DateValue.new(:value=>"1790-07-04", :hits =>@hits_values[3]),
    DateValue.new(:value=>"1790-07-06", :hits =>@hits_values[4])]
    @ranges = Dates2SVG.new(@dates)
  end
  
  describe "date parsing" do
    describe "years" do
      it "should group the years properly" do
        @ranges.years.length.should_not be 0
        @ranges.years.length.should == 3
        @ranges.years.map{|r| r.year }.should == ["1779", "1789", "1790"]
      end
    end
    describe "months" do
      it "should groups the months properly" do
        year_1789 = @ranges.years.select{|y| y.year == "1789" }.first
        year_1789.months.length.should == 4
        year_1789.months.map{|m| m.month }.should == ["01", "03", "06", "07"]
      end
      it "should sum all the hits in the month" do
        year_1790 = @ranges.years.select{|y| y.year == "1790" }.first
        year_1790.months.length.should > 1
        year_1790.months.select{|m| m.month == "07" }.first.hits.should == @hits_values.inject(:+)
      end
    end
  end
  
  describe "max hits" do
    it "should get the maximum number of hits in all months" do
      @ranges.max.should == @hits_values.inject(:+)
    end
  end
  
  describe "colors" do
    describe "color_range" do
      it "should get the default max_hits when one is not provided" do
        range = Dates2SVG.color_range
        range.keys.first.should == [0]
        range[[0]].should == "#EEEEEE"
        range.keys.last.should == (2401..3000)
        range[(2401..3000)].should == "#FF0000"
      end
      it "should use the max option passed to provide a differnt color range" do
        range = Dates2SVG.color_range(:max => 6000)
        range.keys.first.should == [0]
        range[[0]].should == "#EEEEEE"
        range.keys.last.should == (4801..6000)
        range[(4801..6000)].should == "#FF0000"
      end
      it "should use an updated color range if one is provided" do
        colors = ["black", "purple", "blue", "green", "yellow", "red"]
        range = Dates2SVG.color_range(:max => 6000, :color_options => colors)
        range.keys.first.should == [0]
        range[[0]].should == colors.first
        range.keys.last.should == (4801..6000)
        range[(4801..6000)].should == colors.last
      end
      it "should have more range options if additional colors are passed" do
        colors = ["black", "purple", "blue", "green", "yellow", "red"]
        range = Dates2SVG.color_range(:max => 6000, :color_options => colors)
        range.keys.length.should == colors.length
        colors << ["#FF0000", "grey"]
        range = Dates2SVG.color_range(:max => 6000, :color_options => colors)
        range.keys.length.should == colors.length
      end
    end
  end
  
  describe "svg export" do
    describe "options" do
      describe "box size" do
        it "should default to a 15px box size" do
          @ranges.to_svg.should match(/<rect.*width='15' height='15'.*>/)
        end
        it "should change the box size when a box_size option is available" do
          new_range = Dates2SVG.new(@dates, :box_size => "10").to_svg
          new_range.should_not match(/<rect.*width='15' height='15'.*>/)
          new_range.should match(/<rect.*width='10' height='10'.*>/)
        end
      end
      describe "border" do
        it "should default to a 1px border" do
          @ranges.to_svg.should include "<g transform='translate(28,0)'>"
        end
        it "should change the border when a border options is available" do
          border_2 = Dates2SVG.new(@dates, :border => "2").to_svg
          border_2.should_not include "<g transform='translate(28,0)'>"
          border_2.should include "<g transform='translate(29,0)'>"
          
          border_4 = Dates2SVG.new(@dates, :border => "4").to_svg
          border_4.should_not include "<g transform='translate(28,0)'>"
          border_4.should include "<g transform='translate(31,0)'>"
        end
      end
      
      describe "year_range" do
        it "should return only the requested years" do
          @ranges.to_svg.should match(/data-year='1779'/)
          new_range = Dates2SVG.new(@dates, :year_range => (1785..1790))
          new_range.to_svg.should_not match(/data-year='1779'/)
        end
      end
      describe "color_options" do
        it "use the range of color provided" do
          [Dates2SVG.color_options.first, Dates2SVG.color_options.last].each do |color|
            @ranges.to_svg.should match(/fill: #{color};/)
          end
          new_options = ["black", "purple", "blue", "green", "yellow", "red"]
          new_range = Dates2SVG.new(@dates, :color_options => new_options).to_svg
          Dates2SVG.color_options.each do |color|
            new_range.should_not match(/fill: #{color};/)
          end
          [new_options.first, new_options.last].each do |color|
            new_range.should match(/fill: #{color}/)
          end
        end
      end
    end
  end
end