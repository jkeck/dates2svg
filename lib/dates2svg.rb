require "dates2svg/version"

class Dates2SVG
  attr_reader :options
  def initialize(dates, options={})
    @dates = dates
    @options = options
    process_options
    parse_dates
    @options[:color_range] = color_range
    @options[:max] = max
  end
  
  def years
    @years ||= []
  end
  
  def max
    @max ||= years.map{|year| year.months.map{|month| month.hits} }.flatten.max
  end
  
  def color_range
    max_hits = max || 3000
    section = (max_hits) / (@options[:color_options].length - 1)
    colors = {}
    ranges = [[0]]
    
    i = 0
    (@options[:color_options].length - 1).times do
      if i == 0
        ranges << (1..(section * 1))
      elsif ((i+1) == (@options[:color_options].length - 1))
        ranges << (((section * i) + 1)..max_hits)
      else
        ranges << (((section * i) + 1)..(section * (i + 1)))
      end
      i = i+1
    end
    @options[:color_options].each_with_index do |color, index|
      unless ranges[index].is_a?(Range) and [ranges[index].first, ranges[index].last].include?(0)
        colors[ranges[index]] = color
      end
    end
    colors
  end
    
  def to_svg
    svg = ""
    # + 35 and +50 gives us the space for the year month text
    svg << "<svg height='#{(12 * @options[:box_with_border]) + 35}' width='#{(all_years.to_a.length * @options[:box_with_border]) + 50}'>"
      svg << "<g transform='translate(20,35)'>"
        all_years.each_with_index do |year, index|
          selected_years = years.select{|y| y.year.to_i == year.to_i }
          unless selected_years.length == 0
            svg << selected_years.first.to_svg(:index => index)
          else
            svg << Dates2SVG::Year.new(year, [], @options).to_svg(:index => index)
          end
        end
        svg << calendar_year_listing
        svg << calendar_month_listing
      svg << "</g>"
    svg << "</svg>"
  end
  
  private
  
  def parse_dates
    @dates.map do |date|
      date_from_facet_value(date)
    end.sort do |a, b|
      a.year.to_i <=> b.year.to_i
    end.group_by(&:year).each do |year, dates|
      years << Dates2SVG::Year.new(year, dates, @options)
    end
  end

  def date_from_facet_value(facet)
    facet.value[/^(\d{4})-(\d{2})-(\d{2})/]
    Dates2SVG::DateWithValue.new(:year => $1, :month => $2, :day => $3, :hits => facet.hits)
  end

  def all_years
    @options[:year_range] || years.map{|y| y.year }
  end
  
  def calendar_year_listing
    svg = ""
    all_years.each_with_index do |year, index|
      svg << "<text x='3' y='#{(@options[:box_with_border] * index) + 20}' transform='rotate(-90)' class='year'>#{year}</text>"
    end
    svg
  end
  
  def calendar_month_listing
    svg = ""
    ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", " Oct", "Nov", "Dec"].each_with_index do |month, index|
      svg << "<text text-anchor='middle' class='cmonth' dx='0' dy='#{(@options[:box_with_border] * index) + 10}'>#{month}</text>"
    end
    svg
  end
  
  def process_options
    @options = self.class.default_options.merge(@options)
    @options[:box_with_border] = (@options[:box_size].to_i + @options[:border].to_i)
  end
  
  def self.default_options
    {:color_options => ["#EEEEEE", "#330000", "#660000", "#990000", "#CC0000", "#FF0000"],
     :box_size => 15,
     :border => 1,
     :box_with_border => nil
    }
  end
  
  class DateWithValue
    attr_reader :year, :month, :day, :hits
    def initialize(ops={})
      @year = ops[:year]
      @month = ops[:month]
      @day = ops[:day]
      @hits = ops[:hits]
    end
  end
  
  class Year
    attr_reader :year
    def initialize(year, dates, options={})
      @year = year
      @dates = dates
      @options = options
      parse_dates
    end
    
    def months
      @months ||= []
    end
    
    def to_svg(options={})
      svg = ""
      svg << "<g transform='translate(#{(@options[:box_with_border] * options[:index]) + 12},0)'>"
        all_months.each_with_index do |month, index|
          unless months.select{|m| m.month == month}.length == 0
            svg << months.select{|m| m.month == month}.first.to_svg(:index => index)
          else
            svg << Dates2SVG::Month.new(@year, month, [], @options).to_svg(:index => index)
          end
        end
      svg << "</g>"
    end
    
    private
    
    def parse_dates
      @dates.sort do |a, b|
        a.month.to_i <=> b.month.to_i
      end.group_by(&:month).map do |month, dates|
        months << Dates2SVG::Month.new(@year, month, dates, @options)
      end
    end
    
    def all_months
      ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    end
    
  end
  
  class Month
    attr_reader :year, :month
    def initialize(year, month, dates, options={})
      @year = year
      @month = month
      @dates = dates
      @options = options
    end
    def hits
      @hits ||= (@dates.map{|d| d.hits.to_i }.inject(:+) || 0)
    end
    
    def to_svg(options={})
      svg = ""
      svg << "<rect data-hits='#{hits}' data-year='#{@year}' data-month='#{@month}' class='month' width='#{@options[:box_size]}' height='#{@options[:box_size]}' y='#{@options[:box_with_border] * options[:index]}' style='fill: #{color};'>"
        svg << "<title>#{hits} hits on #{@year}-#{@month}</title>"
      svg << "</rect>"
    end
    
    private
    
    def color
      max_hits = @options[:max] || 3000
      section = (max_hits / 5)
      max = section * 5

      return @options[:color_options].last if hits > max
      colors = @options[:color_range]
      begin
        # .first turns the hash into an array and .last gets the value
        colors.select{|k,v| k.include?(hits) }.first.last
      rescue
        @options[:color_options].first
      end
    end
  end
  
end
