[![Build Status](https://travis-ci.org/jkeck/dates2svg.png?branch=master)](https://travis-ci.org/jkeck/dates2svg)

# Dates2svg

Turn an array of simple objects that respond to #value with dates and #hits with a number into an SVG month grid with heat-map.

![date range heat map](http://i.imgur.com/6dcL09C.png)

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
    
### Options

There are various options that can be passed in as an options has upon initialization.  These options are year_range, color_options, box_size, and border.
    
By default you will only get years that occur in the data passed in the dates array.  You can specify a range of years by passing a year_range option.

    svg = Dates2SVG.new(dates, :year_range => (2000..2020)).to_svg

If you would like to change the colors that the grid uses for the heat-map you can specify different colors in the color_options option.

    svg = Dates2SVG.new(dates, :color_options => ["black", "purple", "blue", "green", "yellow", "red"]).to_svg
    
You can see the current range of colors and hits ranges being used in the SVG by accessing in the color_range key in the options hash.  This would be useful in generating a legend.

    color_range = Dates2SVG.new(dates).options[:color_range]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
