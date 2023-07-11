require 'rails_helper'

RSpec.describe Player, type: :model do
  describe '#name_brief' do
    it 'returns the correct format for a baseball player' do
      player = Player.new(first_name: "Francisco", last_name: "Lindor", sport: 0)
      expect(player.name_brief).to eq("F. L.")
    end

    it 'returns the correct format for a basketball player' do
      player = Player.new(first_name: "Jalen", last_name: "Brunson", sport: 1)
      expect(player.name_brief).to eq("Jalen B.")
    end

    it 'returns the correct format for a football player' do
      player = Player.new(first_name: "Saquon", last_name: "Barkley", sport: 2)
      expect(player.name_brief).to eq("S. Barkley")
    end
  end
end
