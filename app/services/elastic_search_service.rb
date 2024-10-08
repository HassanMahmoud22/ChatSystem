class ElasticSearchService

  def self.search(chat_id, query)
    messages = search_in_elasticsearch(chat_id, query)
    format_results(messages)
  end

  private

  def self.search_in_elasticsearch(chat_id, query)
    response = Elasticsearch::Model.client.search(
      index: "messages",
      body: {
        query: {
          bool: {
            must: [
              { match: { body: query } },
              { term: { chat_id: chat_id } }
            ]
          }
        }
      }
    )
    response["hits"]["hits"].map do |hit|
      Message.new(
        body: hit["_source"]["body"],
        message_number: hit["_source"]["message_number"]
      )
    end
  rescue => e
    Rails.logger.error("Error searching in Elasticsearch: #{e.message}")
    []
  end


  def self.index_messages(messages)
    messages.each do |message|
      index_message(message)
    end
  end

  def self.index_message(message)
    message_index = {
      id: message.id,
      chat_id: message.chat_id,
      body: message.body,
      message_number: message.message_number,
      created_at: message.created_at,
      updated_at: message.updated_at
    }

    Elasticsearch::Model.client.index(
      index: "messages",
      id: message.id,
      body: message_index
    )
  end

  def self.format_results(results)
    results.map { |result| result.as_json }
  end
end
