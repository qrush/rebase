class Chartify
  attr_reader :range  

  AXIS_STYLE = {:color => '4183c4', :font_size => 9, :alignment => :right}

  def initialize
    @stop = Date.yesterday
    @start = @stop - 1.week + 1.day
  end

  def line_chart(title, range, &block)
    chartify("530x375", title, GoogleChart::LineChart, block) do |chart|
      chart.axis :x, AXIS_STYLE.merge(:labels => (@start..@stop).map{|d| d.strftime("%m-%d")})
      chart.axis :y, AXIS_STYLE.merge(:range => [0, range])
      chart.fill_area 'bbccd9', 0, 0
    end
  end

  def pie_chart(title, &block)
    chartify("530x220", title, GoogleChart::PieChart, block, :chco => '336699') do |chart|
      chart.is_3d = true
    end
  end

  def meter_chart(title, count, &block)
    chartify("530x175", title, GoogleChart::PieChart, block,
      :cht => "gom", :chd => "t:#{count * 10}", :chl => "#{count.round(2)} events/min")
  end

  protected
    def chartify(size, title, type, data_block, options = {}, &graph_block)
      type.new(size, titlify(title), false) { |chart|
        chart.fill :background, :solid, :color => 'f0f0f0' 
        graph_block.call(chart) if graph_block
        data_block.call(chart) if data_block
      }.to_url(options)
    end

    def titlify(text)
      format = "%m-%d-%Y"
      "GitHub Rebase — #{text} — #{@start.strftime(format)} to #{@stop.strftime(format)}"
    end
end
