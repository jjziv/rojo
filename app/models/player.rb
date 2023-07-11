# Model representing a player. Data is hydrated from the CBS Fantasy Sports API.
class Player < ApplicationRecord
  # This is a computed value and isn't exposed as a query parameter, so there is no need to store it.
  attr_accessor :average_position_age_diff

  enum :sport, { baseball: 0, basketball: 1, football: 2 }

  # Return the appropriately formatted brief name for display purposes.
  #
  # Baseball: first initial and the last initial like “G. S.”
  # Basketball: first name plus last initial like “Kobe B.”
  # Football: first initial and their last name like “P. Manning”
  #
  # @return [String]
  def name_brief
    case self.sport
    when 'baseball'
      "#{self.first_name[0]}. #{self.last_name[0]}."
    when 'basketball'
      "#{self.first_name} #{self.last_name[0]}."
    when 'football'
      "#{self.first_name[0]}. #{self.last_name}"
    else
      ''
    end
  end
end
