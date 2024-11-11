-- +goose Up
-- +goose StatementBegin
CREATE TABLE game_pitchers (
    id serial PRIMARY KEY,
    game_id int NOT NULL references games(id),
    away_start_pitcher_id        int references players(id),
    home_start_pitcher_id        int references players(id),
    winning_pitcher_id               int references players(id),
    losing_pitcher_id              int references players(id),
    saving_pitcher_id              int references players(id)
);

INSERT INTO game_pitchers (game_id, away_start_pitcher_id, home_start_pitcher_id, winning_pitcher_id, losing_pitcher_id, saving_pitcher_id)
SELECT DISTINCT rg.game_id,
         asp.player_id as away_start_pitcher_id,
         hsp.player_id as home_start_pitcher_id,
         wp.player_id as winning_pitcher_id,
         lp.player_id as losing_pitcher_id,
         sp.player_id as saving_pitcher_id
FROM retrosheet.gamelog gl
INNER JOIN ref_games rg
ON CONCAT(gl.home_team,REPLACE(CAST(gl.date as varchar), '-',''),gl.double_header) = rg.retro_game_id
LEFT JOIN ref_players asp
ON asp.retro_player_id = gl.visitor_starting_pitcher_id
LEFT JOIN ref_players hsp
ON hsp.retro_player_id = gl.home_starting_pitcher_id
LEFT JOIN ref_players wp
ON wp.retro_player_id = gl.winning_pitcher_id
LEFT JOIN ref_players lp
ON lp.retro_player_id = gl.losing_pitcher_id
LEFT JOIN ref_players sp
ON sp.retro_player_id = gl.saving_pitcher_id
WHERE gl.acquisition_info = 'Y'
;
-- +goose StatementEnd

-- +goose Down
DROP TABLE game_pitchers cascade;