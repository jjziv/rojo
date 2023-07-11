# frozen_string_literal: true
# Partials don't handle nil values well, so just duplicating the render block for convenience in the interest of time.
json.cache! @player do
  json.id @player.id
  json.name_brief @player.name_brief
  json.first_name @player.first_name
  json.last_name @player.last_name
  json.position @player.position
  json.age @player.age
  json.average_position_age_diff @player.average_position_age_diff
end
