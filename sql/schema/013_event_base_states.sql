-- +goose Up
-- +goose StatementBegin
CREATE TABLE event_base_states (
    event_id int references events(id),
    base_state_id int references base_states(id),
    UNIQUE (event_id)
);
CREATE EXTENSION IF NOT EXISTS tablefunc;
CREATE TEMP TABLE event_pids AS (
    SELECT DISTINCT re.event_id,
                    base_runners.base,
                    p.player_id as  pid
    FROM (SELECT DISTINCT e.game_id,
                          e.event_id,
                          base_order.base,
                          base_order.pid
          FROM retrosheet.event e
                   CROSS JOIN LATERAL (
              VALUES (1, e.base1_run_id), (2, e.base2_run_id), (3, e.base3_run_id)
              ) AS base_order(base, pid)) base_runners
             INNER JOIN ref_events re
                        ON re.retro_game_id = base_runners.game_id
                            AND base_runners.event_id = re.retro_event_id
             INNER JOIN ref_players p
                        ON p.retro_player_id = base_runners.pid
    WHERE base_runners.pid is not null);
INSERT INTO event_base_states (event_id, base_state_id)
SELECT DISTINCT re.event_id,
                bs.id as base_state_id
FROM ref_events re
         LEFT JOIN crosstab(
        'SELECT event_id, base, pid FROM event_pids ORDER BY 1, 2',
        'SELECT DISTINCT base FROM event_pids ORDER BY 1'
                   ) AS ct(event_id int, base_runner1_player_id int, base_runner2_player_id int, base_runner3_player_id int)
                   ON re.event_id = ct.event_id
LEFT JOIN base_states bs
    ON COALESCE(bs.base1_id, 0) = COALESCE(ct.base_runner1_player_id, 0)
    AND COALESCE(bs.base2_id, 0) = COALESCE(ct.base_runner2_player_id, 0)
    AND COALESCE(bs.base3_id, 0) = COALESCE(ct.base_runner3_player_id, 0)
ORDER BY re.event_id;
DROP TABLE event_pids;
-- +goose StatementEnd

-- +goose Down
DROP TABLE event_base_states;