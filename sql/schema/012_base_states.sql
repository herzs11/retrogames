-- +goose Up
-- +goose StatementBegin
CREATE TABLE base_states (
    id serial PRIMARY KEY,
    base1_id int references players(id),
    base2_id int references players(id),
    base3_id int references players(id),
    UNIQUE (base1_id, base2_id, base3_id)
);

INSERT INTO base_states (base1_id, base2_id, base3_id)
SELECT DISTINCT base1.player_id as base1_id,
                base2.player_id as base2_id,
                base3.player_id as base3_id
FROM retrosheet.event e
            LEFT JOIN ref_players base1
                    ON base1.retro_player_id = e.base1_run_id
            LEFT JOIN ref_players base2
                    ON base2.retro_player_id = e.base2_run_id
            LEFT JOIN ref_players base3
                    ON base3.retro_player_id = e.base3_run_id;
-- +goose StatementEnd
-- +goose Down
DROP TABLE base_states cascade;