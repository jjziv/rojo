require 'rest-client'
require 'json'

namespace :cbs do
  desc "Pull all player data from the CBS Fantasy Sports API and update our application's data."
  task :update_player_data => :environment do
    # Delete all local data (in a real situation, we'd likely just want to make any delta updates).
    puts "Deleting all data!"
    Player.destroy_all

    url = "https://api.cbssports.com/fantasy/players/list?version=3.0&response_format=JSON"
    cache_key = "average_age_by_position_for_sport:"

    # Loop through each valid sport and update the player data.
    Player.sports.keys.each do |s|
      puts "Updating sport: #{s}"

      response = RestClient.get(url + "&SPORT=#{s}")
      parsed_response = JSON.parse(response.body)

      player_data = parsed_response['body']['players']

      puts "Number of players to update: #{player_data.size}"

      unless player_data.nil?
        player_data.each do |p|
          Player.create!(
            first_name: p.fetch('firstname'),
            last_name: p.fetch('lastname'),
            sport: Player.sports[s],
            team: p.fetch('pro_team'),
            position: p.fetch('position'),
            age: p.fetch('age', nil)
          )
        end
      end

      puts "Number of players updated: #{Player.where(sport: s).count}"

      # Update our cached average age by position data.
      player_data = Player.where(sport: s).group(:position).average(:age)

      player_data.each { |k, v| player_data[k] = v.round if player_data[k].present? }

      key = cache_key + "#{s}"
      Rails.cache.fetch(key, :expires_in => 1.week) do
        player_data.to_json
      end

      puts "Age data updated: #{player_data}"
    rescue StandardError => e
      puts "There was an error: #{e.message}"
      next
    end
  end
end
