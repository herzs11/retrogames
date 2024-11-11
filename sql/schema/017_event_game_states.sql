-- +goose Up
-- -- +goose StatementBegin
CREATE TABLE event_game_states (
    event_id int references events(id),
    game_state_id int references game_states(id),
    UNIQUE(event_id, game_state_id)
);

INSERT INTO event_game_states (event_id, game_state_id)
SELECT DISTINCT re.event_id,
                gs.id as game_state_id
FROM ref_events re
INNER JOIN retrosheet.event e
ON re.retro_game_id = e.game_id
AND re.retro_event_id = e.event_id
INNER JOIN game_states gs
ON e.away_score_ct = gs.away_score
AND e.home_score_ct = gs.home_score
AND e.outs_ct = gs.outs
AND e.balls_ct = gs.balls
AND e.strikes_ct = gs.strikes;
-- +goose StatementEnd
-- +goose Down
DROP TABLE event_game_states cascade;