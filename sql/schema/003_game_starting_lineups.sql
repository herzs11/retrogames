-- +goose Up
-- +goose StatementBegin
create table game_starting_lineups (
    id              serial primary key,
    game_id          int references games(id),
    team             varchar(1024) not null,
    batting_position smallint not null,
    player_id        int references players(id),
    fielding_position smallint not null,
    UNIQUE (game_id, team, batting_position)
);

INSERT INTO game_starting_lineups (game_id, team, batting_position, player_id, fielding_position)
with retro_lineup as (
    SELECT DISTINCT
        CONCAT(home_team,REPLACE(CAST(date as varchar), '-',''),double_header) as retro_gid,
        unnest(array['away', 'away', 'away', 'away', 'away', 'away', 'away', 'away', 'away',
            'home', 'home', 'home', 'home', 'home', 'home', 'home', 'home', 'home']) AS team,
        unnest(array[1, 2, 3, 4, 5, 6, 7, 8, 9,
            1, 2, 3, 4, 5, 6, 7, 8, 9]) AS batting_position,
        unnest(array[visitor_batting_1_player_id, visitor_batting_2_player_id, visitor_batting_3_player_id, visitor_batting_4_player_id, visitor_batting_5_player_id,
            visitor_batting_6_player_id, visitor_batting_7_player_id, visitor_batting_8_player_id, visitor_batting_9_player_id,
            home_batting_1_player_id, home_batting_2_player_id, home_batting_3_player_id, home_batting_4_player_id, home_batting_5_player_id,
            home_batting_6_player_id, home_batting_7_player_id, home_batting_8_player_id, home_batting_9_player_id]) AS retro_pid,
        unnest(array[visitor_batting_1_position, visitor_batting_2_position, visitor_batting_3_position, visitor_batting_4_position,
            visitor_batting_5_position, visitor_batting_6_position, visitor_batting_7_position, visitor_batting_8_position,visitor_batting_9_position,
            home_batting_1_position, home_batting_2_position, home_batting_3_position, home_batting_4_position,
            home_batting_5_position, home_batting_6_position, home_batting_7_position, home_batting_8_position,home_batting_9_position]) AS fielding_position
    FROM retrosheet.gamelog
    WHERE acquisition_info = 'Y')
SELECT DISTINCT rg.game_id,
                rl.team,
                rl.batting_position,
                p.player_id,
                rl.fielding_position
FROM retro_lineup rl
INNER JOIN ref_games rg
    ON rl.retro_gid = rg.retro_game_id
INNER JOIN ref_players p
ON rl.retro_pid = p.retro_player_id
ORDER BY rg.game_id;
-- +goose StatementEnd

-- +goose Down
drop table if exists game_starting_lineups cascade;
