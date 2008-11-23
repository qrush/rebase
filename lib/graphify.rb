class Graphify
  GRAPH_SIZE = "530x375"
  
  def initialize
    @start = Date.today.to_datetime
    @stop = @start - 1.week
  end

  def line_chart(title, &block)
    graphify(title, GoogleChart::LineChart, block)
  end


  protected
    def graphify(title, type, block)
      type.new(GRAPH_SIZE, titlify(title), false) { |chart|
        block.call(chart)
      }.to_url
    end

    def titlify(text)
      "GitHub Rebase — #{text} — #{@start.to_formatted_s(:date)} to #{@stop.to_formatted_s(:date)}"
    end
end
