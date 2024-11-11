-- +goose Up
-- +goose StatementBegin
CREATE TABLE fielding_states (
    id serial PRIMARY KEY,
    pos1_id int references players(id),
    pos2_id int references players(id),
    pos3_id int references players(id),
    pos4_id int references players(id),
    pos5_id int references players(id),
    pos6_id int references players(id),
    pos7_id int references players(id),
    pos8_id int references players(id),
    pos9_id int references players(id),
    UNIQUE (pos1_id, pos2_id, pos3_id, pos4_id, pos5_id, pos6_id, pos7_id, pos8_id, pos9_id)
);
INSERT INTO fielding_states (pos1_id, pos2_id, pos3_id, pos4_id, pos5_id, pos6_id, pos7_id, pos8_id, pos9_id)
SELECT distinct pit.player_id as pos1_id,
                pos2.player_id as pos2_id,
                pos3.player_id as pos3_id,
                pos4.player_id as pos4_id,
                pos5.player_id as pos5_id,
                pos6.player_id as pos6_id,
                pos7.player_id as pos7_id,
                pos8.player_id as pos8_id,
                pos9.player_id as pos9_id
FROM retrosheet.event e
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
WHERE e.pit_id IS NOT NULL;
-- +goose StatementEnd

-- +goose Down
DROP TABLE fielding_states cascade;