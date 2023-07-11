require 'rails_helper'

RSpec.describe "PlayersControllers", type: :request do
  baseball_average_age_data = {"INF"=>nil, "SS"=>27, "DH"=>31, "CF"=>27, "2B"=>29, "C"=>29, "RP"=>30, "SP"=>27, "PS"=>nil, "LF"=>29, "RF"=>28, "null"=>nil, "1B"=>30, "3B"=>28}

  describe "#show" do
    context 'error conditions' do
      it 'raises an error when no ID is passed in' do
        expect { get players_path + "?id=" }.to raise_error(ActionController::ParameterMissing)
      end

      it 'raises an error when the player is not found' do
        expect { get players_path + "?id=0" }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    before do
      allow(Rails.cache).to receive(:fetch).and_return(
        baseball_average_age_data.to_json
      )
    end
    it 'returns expected data for a valid ID' do
      player = Player.create!(first_name: "Francisco", last_name: "Lindor", sport: 0, team: "NYM", position: "SS", age: 29)

      get players_path + "?id=#{player.id}"

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body)
      expect(parsed_response.fetch('id')).to eq(player.id)
      expect(parsed_response.fetch('name_brief')).to eq(player.name_brief)
      expect(parsed_response.fetch('first_name')).to eq(player.first_name)
      expect(parsed_response.fetch('last_name')).to eq(player.last_name)
      expect(parsed_response.fetch('position')).to eq(player.position)
      expect(parsed_response.fetch('age')).to eq(player.age)
      expect(parsed_response.fetch('average_position_age_diff')).to eq((baseball_average_age_data[player.position] - player.age.to_i).abs)
    end
  end

  describe "#search" do
    let(:sport) { 'baseball'}
    let(:last_name) { 'l' }
    let(:age) { 29 }
    let(:age_range) { 29..35 }
    let(:position) { 'ss' }

    context 'error conditions' do
      it 'raises an error when no valid search parameter is passed in' do
        expect { get search_players_path + "?id=12345" }.to(raise_error do |error|
                                                              expect(error).to be_a(StandardError)
                                                              expect(error.message).to eq("Please enter a valid search param!")
                                                            end
        )
      end
    end

    it 'supports searching by sport' do
      get search_players_path + "?sport=#{sport}"

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body)

      expect(parsed_response.size).to eq(Player.where(sport: sport.downcase).count)
    end

    it 'supports searching by last_name' do
      get search_players_path + "?sport=#{sport}&last_name=#{last_name}"

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body)

      expect(parsed_response.size).to eq(Player.where(sport: sport.downcase).where('last_name ILIKE ?', "#{last_name}%").count)
    end

    context 'age' do
      it 'supports searching by single age' do
        get search_players_path + "?sport=#{sport}&last_name=#{last_name}&age=#{age}"

        expect(response).to be_successful

        parsed_response = JSON.parse(response.body)

        expect(parsed_response.size).to eq(Player.where(sport: sport.downcase, age: age).where('last_name ILIKE ?', "#{last_name}%").count)
      end

      it 'supports searching by age range' do
        get search_players_path + "?sport=#{sport}&last_name=#{last_name}&age=#{age_range}"

        expect(response).to be_successful

        parsed_response = JSON.parse(response.body)

        expect(parsed_response.size).to eq(Player.where(sport: sport.downcase, age: age_range).where('last_name ILIKE ?', "#{last_name}%").count)
      end
    end


    it 'supports searching by position' do
      get search_players_path + "?sport=#{sport}&last_name=#{last_name}&position=#{position}"

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body)

      expect(parsed_response.size).to eq(Player.where(sport: sport.downcase, position: position.upcase).where('last_name ILIKE ?', "#{last_name}%").count)
    end
  end
end
