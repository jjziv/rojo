# rojo
A basic Ruby project template for a Backend API.

This project can be used to rapidly spin up an HTTP based API in Ruby + RoR. Within this repo,
you'll find a minimal use of design patterns and external libraries to create an idiomatic
API complete with test coverage.

## Getting Started
- Install dependencies via Bundler &rarr; `bundle install`
- Run the migration to create the `Players` table in the local environment &rarr; `rake db:migrate`
- Run the rake task to populate the initial set of data ( or wait a week for it to run via the cron schedule :D ) &rarr; `rake cbs:update_player_data`

## Endpoints

### /player
- This app has a basic get endpoint configured to return data for a specific player.

    - Endpoint is available at `http://localhost:3000/players`

    - The endpoint takes a single `id` parameter as a string and returns all relevant data, e.g. ` http://localhost:3000/players?id=12345`


### /player/search
- This app has a search endpoint configured to search for any players that satisfy the search criteria.

    - Endpoint is available at `http://localhost:3000/players/search`

    - The endpoint supports the following parameters and returns all relevant data, e.g. ` http://localhost:3000/players/search?sport=baseball`

        - `sport`     &rarr; case insensitive
        - `last_name` &rarr; The first letter of the player's last name, case insensitive.
        - `age`       &rarr; Either a single age or an age range, e.g. `age=29` OR `age=29..35`
        - `position`  &rarr; case insensitive

## Tests
- Some simple tests around the `Player.name_brief()` logic and the supported Controller requests have been created. Those can be run using `rspec`.

## Tasks

### cbs:update_player_data
- This app has a single rake task that is scheduled to update all player data on a weekly cadence &rarr; `lib/tasks/update_player_data.rake`. For each configured sport in the `Player.sport` enum, the task pulls the player data and saves it to our database.

## Infra
Went with basic file caching here, but if this was a Production type API, I would expect memcache or redis to be available to use that supports more robust data types.

- There's a few layers of caching here:

    - Rails file caching of the Player search results
    - Rails file caching of the average age by sport x position data
    - View level caching of the JSON response


