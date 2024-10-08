class Message < ApplicationRecord
  belongs_to :chat

  validates :message_number, uniqueness: { scope: :chat_id }
  validates :body, presence: true

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mappings dynamic: "false" do
      indexes :body, type: "text", analyzer: "english"
    end
  end

  def as_json(options = {})
    super(options.merge(except: [ :id, :chat_id, :created_at, :updated_at ]))
  end

  def as_indexed_json(options = {})
    Rails.logger.info "Getting message from elastic search"
    as_json(only: [ :body ])
  end
end
