-- +goose Up
-- +goose StatementBegin
CREATE TABLE event_batters (
    event_id int references events(id),
    batter_id int references players(id),
    batter_pos int,
    batter_handedness char(1),
    pinch_hitter boolean,
    removed_hitter_id int references players(id),
    removed_hitter_pos int,
    on_deck_batter_id int references players(id),
    in_hold_batter_id int references players(id),
    UNIQUE (event_id)
);
INSERT INTO event_batters (event_id, batter_id, batter_pos, batter_handedness, pinch_hitter, removed_hitter_id, removed_hitter_pos, on_deck_batter_id, in_hold_batter_id)
SELECT DISTINCT re.event_id,
                p1.player_id as batter_id,
                e.bat_fld_cd as batter_pos,
                e.bat_hand_cd as batter_handedness,
                e.ph_fl as pinch_hitter,
                p2.player_id as removed_hitter_id,
                e.removed_for_ph_bat_fld_cd as removed_hitter_pos,
                p3.player_id as on_deck_batter_id,
                p4.player_id as in_hold_batter_id
    FROM ref_events re
         INNER JOIN retrosheet.event e
                    ON re.retro_game_id = e.game_id
                        AND re.retro_event_id = e.event_id
         INNER JOIN ref_players p1
                    ON p1.retro_player_id = e.bat_id
         LEFT JOIN ref_players p2
                   on p2.retro_player_id = e.removed_for_ph_bat_id
         LEFT JOIN ref_players p3
                   on p3.retro_player_id = e.bat_on_deck_id
         LEFT JOIN ref_players p4
                   on p4.retro_player_id = e.bat_in_hold_id
ORDER BY re.event_id;
-- +goose StatementEnd

-- +goose Down
DROP TABLE event_batters cascade;