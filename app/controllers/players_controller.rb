# frozen_string_literal: true
# Player API - Provides basic get functionality for a player by ID and search functionality by multiple query parameters.
class PlayersController < ApplicationController
  AGE_DATA_CACHE_KEY = "average_age_by_position_for_sport:".freeze

  PLAYER_DATA_CACHE_KEY = "player_data_search_param_".freeze

  # Basic fetch endpoint: /players?id=
  #
  # @param [Integer] id The ID of the player you want to fetch data for.
  def show
    player_id = params.require(:id)

    @player = Player.find_by!(id: player_id)

    average_age_by_position = self.get_average_age_by_position(sport: @player.sport, position: @player.position)

    @player.average_position_age_diff = if @player.age.nil?
                                          0
                                        else
                                          (average_age_by_position - @player.age).abs
                                        end

    render "players/show", formats: :json
  end

  # Search endpoint: /players/search?
  #
  # @param [String] sport     The sport we want to search for.
  # @param [String] last_name The first letter of the last name we want to search for.
  # @param [String] age       The age we want to search for - accepts either a single age or a range, e.g. 25..30.
  # @param [String] position  The position we want to search for.
  def search
    raise StandardError, "Please enter a valid search param!" if search_params.empty?

    @players = Rails.cache.fetch(self.build_cache_key, :expires_in => 1.minute) do
      self.get_player_data.to_json
    end

    @players = JSON.parse(@players, object_class: Player)

    @players.each do |player|
      average_age_by_position = self.get_average_age_by_position(sport: player.sport, position: player.position)

      player.average_position_age_diff = if player.age.nil?
                                           0
                                         else
                                           (average_age_by_position - player.age).abs
                                         end
    end

    render "players/search", formats: :json
  end

  private

  # Get the precomputed average age data by position.
  #
  # @param [String] sport    The sport we want data for.
  # @param [String] position The position we want_data_for.
  #
  # @return [Integer]
  def get_average_age_by_position(sport:, position:)
    age_data = Rails.cache.fetch(AGE_DATA_CACHE_KEY + sport)

    return 0 if age_data.nil?

    age_data = JSON.parse(age_data)

    age_data[position] || 0
  end

  # Build the cache key based on the given search criteria.
  #
  # @return [String]
  def build_cache_key
    key = PLAYER_DATA_CACHE_KEY

    search_params.each do |k, v|
      key += "_#{k}:#{v}"
    end

    key
  end

  # Enforces the valid search params we support.
  def search_params
    params.permit(%i[sport last_name age position])
  end

  # Get the data for the players that satisfy the given search criteria.
  def get_player_data
    players = Player.order(:id)

    if search_params[:sport].present?
      players = players.where(sport: Player.sports[search_params[:sport].downcase])
    end

    if search_params[:last_name].present?
      players = players.where('last_name ILIKE ?', "#{search_params[:last_name]}%")
    end

    if search_params[:age].present?
      age_range = search_params[:age].split('..').map(&:to_i)

      age_query = if age_range.size > 1
                    age_range[0]..age_range[1]
                  else
                    age_range[0]
                  end

      players = players.where(age: age_query)
    end

    if search_params[:position].present?
      players = players.where(position: search_params[:position].upcase) # For position search to uppercase since that is how it is stored in the DB.
    end

    players
  end
end
