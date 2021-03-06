class Impl::DataProviders::ReusableBuilder
  include Sidekiq::Worker
  sidekiq_options backtrace: true

  def perform(aggregation_id)
    aggregation = Impl::Aggregation.find(aggregation_id)
    aggregation.update_attributes(status: "Building Reusables", error_messages: nil)
    begin
      europeana_query = aggregation.europeana? ? "*:*" : CGI.escape("#{aggregation.genre.upcase}:\"#{(aggregation.name)}\"")
      reusables = Nestful.get("http://www.europeana.eu/api/v2/search.json?wskey=SQkKyghXb&query=#{europeana_query}&facet=REUSABILITY&profile=facets&rows=0")
      if reusables["facets"].present? and reusables["facets"].first.present? and reusables["facets"].first['fields'].present?
        reusable_data =  reusables["facets"].first['fields'].map{|a| {"month" => Date.today.month, "year" => Date.today.year, "reusable" => a["label"], "value" => a["count"].to_i}}
        Core::TimeAggregation.create_aggregations(reusable_data,"monthly", aggregation_id,"Impl::Aggregation","value","reusable")
        aggregation.update_attributes(status: "Processed Reusables")
      else
        raise "No reusable detected"
      end
    rescue => e
      aggregation.update_attributes(status: "Failed to build reusables", error_messages: e.to_s)
    end
  end
end