-- +goose Up
-- +goose StatementBegin
CREATE TABLE event_subs (
    id serial PRIMARY KEY,
    event_id int references events(id),
    home_team_sub boolean,
    player_id int references players(id),
    fielding_position smallint,
    bat_order smallint,
    subbed_player_id int references players(id),
    subbed_player_fielding_position smallint
);

INSERT INTO event_subs (event_id, home_team_sub, player_id, fielding_position, bat_order, subbed_player_id, subbed_player_fielding_position)
SELECT DISTINCT re.event_id,
                sb.sub_home_id as home_team_sub,
                p.player_id,
                sb.sub_fld_cd as fielding_position,
                sb.sub_lineup_id as bat_order,
                sp.player_id as subbed_player_id,
                sb.removed_fld_cd as subbed_player_fielding_position
FROM retrosheet.sub sb
            INNER JOIN ref_events re
                        ON sb.game_id = re.retro_game_id
                            AND sb.event_id = re.retro_event_id
            INNER JOIN ref_players p
                        ON p.retro_player_id = sb.sub_id
            INNER JOIN ref_players sp
                        ON sp.retro_player_id = sb.removed_id;
-- +goose StatementEnd
-- +goose Down
DROP TABLE event_subs cascade;