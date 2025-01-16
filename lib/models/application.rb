class Application < ActiveRecord::Base
  belongs_to :user

  validates :quantity, numericality: { greater_than: 0 }, if: :needs_validation?
  validates :phone_number, format: { with: /\A[\d\+]{10,}\z/ }, if: :needs_validation?
  validates :delivery_address, length: { minimum: 5 }, if: :needs_validation?
  validates :reference_number, uniqueness: true, if: :needs_validation?

  def completed?
    application_step == 'completed'
  end

  def self.get_products(language)
    Rails.cache.fetch("products_#{language}", expires_in: 1.day) do
      AVAILABLE_PRODUCTS[language]
    end
  end

  def self.find_product(language, code)
    get_products(language).find { |p| p[:code] == code }
  end

  AVAILABLE_PRODUCTS = {
    'ru' => [
      {
        code: 'oak_firewood',
        name: '🌳 Дубовые дрова',
        description: "▫️ Дубовые дрова колотые\n▫️ Цена: 1500 лей за складометр\n▫️ Доставка по всей Молдове",
        price: 1500.0
      },
      {
        code: 'acacia_firewood',
        name: '🌳 Акациевые дрова',
        description: "▫️ Акациевые дрова колотые\n▫️ Цена: 1300 лей за складометр\n▫️ Доставка по всей Молдове",
        price: 1300.0
      }
    ].freeze,
    'ro' => [
      {
        code: 'oak_firewood',
        name: '🌳 Lemne de stejar',
        description: "▫️ Lemne de stejar tăiate\n▫️ Preț: 1500 lei per ster\n▫️ Livrare în toată Moldova",
        price: 1500.0
      },
      {
        code: 'acacia_firewood',
        name: '🌳 Lemne de salcâm',
        description: "▫️ Lemne de salcâm tăiate\n▫️ Preț: 1300 lei per ster\n▫️ Livrare în toată Moldova",
        price: 1300.0
      }
    ].freeze
  }.freeze

  private

  def needs_validation?
    status != 'draft' && application_step == 'completed'
  end
end 