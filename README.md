# Dates2svg

Turn an array of simple objects including dates and values into an SVG month grid with heatmap.

![my image](http://i.imgur.com/6dcL09C.png)

## Installation

Add this line to your application's Gemfile:

    gem 'dates2svg'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dates2svg

## Usage

You will need an array of objects that respond to value with a string in a YYYY-MM-DD format (things at the end like timestamps are okay) and respond to hits with a number.

    dates = [OpenStruct.new(:value => "2013-01-22", :hits => 100), 
             OpenStruct.new(:value => "2013-01-05", :hits => 140),
             OpenStruct.new(:value => "2013-01-12", :hits => 10)]
             
Passing that array to Dates2SVG.new will give you your object that you can get the SVG from.

    svg = Dates2SVG.new(dates).to_svg
    
By default you will only get years that occur in the data passed in the dates array.  You can specify a range of years by passing a year_range option.

    svg = Dates2SVG.new(dates, :year_range => (2000..2020)).to_svg

If you would like to change the colors that the grid uses for the heatmap you can specify differnt colors in the color_options option.

    svg = Dates2SVG.new(dates, :color_options => ["black", "purple", "blue", "green", "yellow", "red"]).to_svg
    
You can see the current range of colors being used in the SVG by calling the color_range method on the Dates2SVG object.

    color_range = Dates2SVG.new(dates).color_range

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
