module ProductService
  class << self
    def available_products(language)
      Rails.cache.fetch("products_#{language}", expires_in: 1.hour) do
        Application::AVAILABLE_PRODUCTS[language]
      end
    end

    def find_product(language, code)
      available_products(language).find { |p| p[:code] == code }
    end
  end
end 