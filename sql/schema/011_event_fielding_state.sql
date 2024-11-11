-- +goose Up
-- +goose StatementBegin
CREATE TABLE event_fielding_states (
    event_id int references events(id),
    fielding_state_id int references fielding_states(id),
    UNIQUE (event_id, fielding_state_id)
);
INSERT INTO event_fielding_states (event_id, fielding_state_id)
SELECT distinct re.event_id,
                rfs.id as fielding_state_id
FROM retrosheet.event e
         INNER JOIN ref_events re
                    ON e.game_id = re.retro_game_id
                        AND e.event_id = re.retro_event_id
         LEFT JOIN ref_players pit
                   ON pit.retro_player_id = e.pit_id
         LEFT JOIN ref_players pos2
                   ON pos2.retro_player_id = e.pos2_fld_id
         LEFT JOIN ref_players pos3
                   ON pos3.retro_player_id = e.pos3_fld_id
         LEFT JOIN ref_players pos4
                   ON pos4.retro_player_id = e.pos4_fld_id
         LEFT JOIN ref_players pos5
                   ON pos5.retro_player_id = e.pos5_fld_id
         LEFT JOIN ref_players pos6
                   ON pos6.retro_player_id = e.pos6_fld_id
         LEFT JOIN ref_players pos7
                   ON pos7.retro_player_id = e.pos7_fld_id
         LEFT JOIN ref_players pos8
                   ON pos8.retro_player_id = e.pos8_fld_id
         LEFT JOIN ref_players pos9
                   ON pos9.retro_player_id = e.pos9_fld_id
         LEFT JOIN fielding_states rfs
                   ON rfs.pos1_id = pit.player_id
                       AND rfs.pos2_id = pos2.player_id
                       AND rfs.pos3_id = pos3.player_id
                       AND rfs.pos4_id = pos4.player_id
                       AND rfs.pos5_id = pos5.player_id
                       AND rfs.pos6_id = pos6.player_id
                       AND rfs.pos7_id = pos7.player_id
                       AND rfs.pos8_id = pos8.player_id
                       AND rfs.pos9_id = pos9.player_id
ORDER BY re.event_id;
-- +goose StatementEnd

-- +goose Down
DROP TABLE event_fielding_states cascade;