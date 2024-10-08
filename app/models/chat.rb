class Chat < ApplicationRecord
  belongs_to :application
  has_many :messages, dependent: :destroy

  validates :chat_number, uniqueness: { scope: :application_id }
  def as_json(options = {})
    super(options.merge(except: [ :id, :application_id, :created_at, :updated_at ]))
  end
end
