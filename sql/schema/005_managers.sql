-- +goose Up
-- +goose StatementBegin
CREATE TABLE game_managers (
    id serial PRIMARY KEY,
    game_id int NOT NULL references games(id),
    away_manager_id          int references players(id),
    home_manager_id          int references players(id)
);
INSERT INTO game_managers (game_id, away_manager_id, home_manager_id)
SELECT DISTINCT rg.game_id,
         am.player_id as away_manager_id,
         hm.player_id as home_manager_id
FROM retrosheet.gamelog gl
INNER JOIN ref_games rg
ON CONCAT(gl.home_team,REPLACE(CAST(gl.date as varchar), '-',''),gl.double_header) = rg.retro_game_id
INNER JOIN ref_players am
ON am.retro_player_id = gl.visitor_manager_id
INNER JOIN ref_players hm
ON hm.retro_player_id = gl.home_manager_id
WHERE gl.acquisition_info = 'Y';
--  +goose StatementEnd

-- +goose Down
DROP TABLE game_managers cascade;