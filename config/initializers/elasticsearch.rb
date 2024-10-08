require "elasticsearch/model"

Elasticsearch::Model.client = Elasticsearch::Client.new(
  host: "#{ENV["ELASTICSEARCH_URL"] || "http://elasticsearch:9200"}",
  log: true
)