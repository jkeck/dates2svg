require "dates2svg/version"

class Dates2SVG
  BOX_SIZE = 15
  BORDER = 1
  BOX_WITH_BORDER = (BOX_SIZE + BORDER)
  def initialize(dates, options={})
    @dates = dates
    @options = options
    parse_dates
  end

  def parse_dates
    @dates.map do |date|
      date_from_facet_value(date)
    end.sort do |a, b|
      a.year.to_i <=> b.year.to_i
    end.group_by(&:year).each do |year, dates|
      years << Dates2SVG::Year.new(year, dates)
    end
  end
  
  def date_from_facet_value(facet)
    facet.value[/^(\d{4})-(\d{2})-(\d{2})/]
    Dates2SVG::DateWithValue.new(:year => $1, :month => $2, :day => $3, :hits => facet.hits)
  end
  
  def years
    @years ||= []
  end
  
  def max
    @max ||= years.map{|year| year.months.map{|month| month.hits} }.flatten.max
  end
  
  def color_range
    self.class.color_range(@options.merge(:max => @max))
  end
  
  def color_options
    @options[:color_options] || self.class.color_options
  end
  
  def to_svg
    svg = ""
    # + 35 and +50 gives us the space for the year month text
    svg << "<svg height='#{(12 * BOX_WITH_BORDER) + 35}' width='#{(all_years.to_a.length * BOX_WITH_BORDER) + 50}'>"
      svg << "<g transform='translate(20,35)'>"
        all_years.each_with_index do |year, index|
          selected_years = years.select{|y| y.year.to_i == year.to_i }
          unless selected_years.length == 0
            svg << selected_years.first.to_svg(@options.merge(:index => index, :max => max))
          else
            svg << Dates2SVG::Year.new(year, []).to_svg(@options.merge(:index => index, :max => max))
          end
        end
        svg << calendar_year_listing
        svg << calendar_month_listing
      svg << "</g>"
    svg << "</svg>"
  end
  
  def self.color_range(options={})
    color_options = options[:color_options] || self.color_options
    max_hits = options[:max] || 3000
    section = (max_hits) / (color_options.length - 1)
    colors = {}
    ranges = [[0]]
    i = 0
    (color_options.length - 1).times do
      if i == 0
        ranges << (1..(section * 1))
      elsif ((i+1) == (color_options.length - 1))
        ranges << (((section * i) + 1)..max_hits)
      else
        ranges << (((section * i) + 1)..(section * (i + 1)))
      end
      i = i+1
    end
    color_options.each_with_index do |color, index|
      unless ranges[index].is_a?(Range) and [ranges[index].first, ranges[index].last].include?(0)
        colors[ranges[index]] = color
      end
    end
    colors
  end
  
  def self.color_options(options={})
    options[:color_options] || ["#EEEEEE", "#330000", "#660000", "#990000", "#CC0000", "#FF0000"]
  end
  
  private
  
  def all_years
    @options[:year_range] || years.map{|y| y.year }
  end
  
  def calendar_year_listing
    svg = ""
    all_years.each_with_index do |year, index|
      svg << "<text x='3' y='#{(BOX_WITH_BORDER * index) + 20}' transform='rotate(-90)' class='year'>#{year}</text>"
    end
    svg
  end
  
  def calendar_month_listing
    svg = ""
    ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", " Oct", "Nov", "Dec"].each_with_index do |month, index|
      svg << "<text text-anchor='middle' class='cmonth' dx='0' dy='#{(BOX_WITH_BORDER * index) + 10}'>#{month}</text>"
    end
    svg
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
    def initialize(year, dates)
      @year = year
      @dates = dates
      parse_dates
    end
    
    def parse_dates
      @dates.sort do |a, b|
        a.month.to_i <=> b.month.to_i
      end.group_by(&:month).map do |month, dates|
        months << Dates2SVG::Month.new(@year, month, dates)
      end
    end
    
    def months
      @months ||= []
    end
    
    def to_svg(options={})
      svg = ""
      svg << "<g transform='translate(#{(BOX_WITH_BORDER * options[:index]) + 12},0)'>"
        all_months.each_with_index do |month, index|
          unless months.select{|m| m.month == month}.length == 0
            svg << months.select{|m| m.month == month}.first.to_svg(options.merge(:index => index))
          else
            svg << Dates2SVG::Month.new(@year, month, []).to_svg(options.merge(:index => index))
          end
        end
      svg << "</g>"
    end
    
    private
    
    def all_months
      ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    end
    
  end
  
  class Month
    attr_reader :year, :month
    def initialize(year, month, dates)
      @year = year
      @month = month
      @dates = dates
    end
    def hits
      @hits ||= (@dates.map{|d| d.hits.to_i }.inject(:+) || 0)
    end
    
    def to_svg(options={})
      svg = ""
      svg << "<rect data-hits='#{hits}' data-year='#{@year}' data-month='#{@month}' class='month' width='#{BOX_SIZE}' height='#{BOX_SIZE}' y='#{BOX_WITH_BORDER * options[:index]}' style='fill: #{color(options)};'>"
        svg << "<title>#{hits} hits on #{@year}-#{@month}</title>"
      svg << "</rect>"
    end
    
    private
    
    def color(options={})
      max_hits = options[:max] || 3000
      section = (max_hits / 5)
      max = section * 5

      return Dates2SVG.color_options(options).last if hits > max
      colors = Dates2SVG.color_range(options)
      begin
        # .first turns the hash into an array and .last gets the value
        colors.select{|k,v| k.include?(hits) }.first.last
      rescue
        Dates2SVG.color_options(options).first
      end
    end
  end
  
end
