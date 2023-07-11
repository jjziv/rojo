class CreatePlayerTable < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :sport, default: 0
      t.string :team, null: false
      t.string :position, null: false
      t.integer :age

      t.timestamps
    end

    # Access patterns we want to support:
    #   - Sport
    #   - First letter of last name
    #   - A specific age (ex. 25)
    #   - A range of ages (ex. 25 - 30)
    #   - The player’s position (ex: “QB”)

    add_index :players, :sport
    add_index :players, :last_name
    add_index :players, :age
    add_index :players, :position
  end
end