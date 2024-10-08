class Application < ApplicationRecord

  has_many :chats
  before_validation :generate_token, on: :create

  validates :name, presence: true
  validates :token, presence: true, uniqueness: true

  def as_json(options = {})
    super(options.merge(except: [:id, :created_at, :updated_at]))
  end
  private

  def generate_token
    self.token = SecureRandom.hex(16) if token.blank?
  end
end
