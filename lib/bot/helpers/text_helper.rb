module TextHelper
  def self.pluralize_ster(number)
    return "складометр" if number == 1
    return "складометра" if [2, 3, 4].include?(number % 10) && ![12, 13, 14].include?(number % 100)
    "складометров"
  end

  def self.pluralize_ster_ro(number)
    return "ster" if number == 1
    "steri"
  end
end 