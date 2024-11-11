-- +goose Up
-- +goose StatementBegin
CREATE TABLE events (
    id serial PRIMARY KEY,
    plate_appearance_id int NOT NULL references plate_appearances(id),
    event_sequence int,
    pitch_count int,
    batter_event boolean,
    UNIQUE (plate_appearance_id, event_sequence)
);
CREATE TABLE ref_events (
    event_id int references events(id),
    retro_game_id char(12),
    retro_event_id int
);
CREATE TABLE ref_retro_events AS (
    SELECT DISTINCT pa.plate_appearance_id,
                    pa.retro_game_id,
                    events.event_id as retro_event_id,
                    length(translate(events.pitch_seq_tx, '123.*+>N', '')) as pitch_count,
                    ROW_NUMBER() over (PARTITION BY pa.plate_appearance_id ORDER BY events.event_id) as event_sequence,
                    events.bat_event_fl as batter_event
    FROM retrosheet.event pa_event
    INNER JOIN ref_plate_appearances pa
        ON pa_event.game_id = pa.retro_game_id
        AND pa_event.event_id = pa.retro_event_id
    INNER JOIN retrosheet.event events
        ON pa_event.game_id = events.game_id
        AND pa_event.inn_ct = events.inn_ct
        AND pa_event.bat_home_id = events.bat_home_id
        AND pa_event.inn_pa_ct = events.inn_pa_ct
);
INSERT INTO events (plate_appearance_id, event_sequence, pitch_count, batter_event)
SELECT DISTINCT plate_appearance_id, event_sequence, pitch_count, batter_event FROM ref_retro_events;

INSERT INTO ref_events (event_id, retro_game_id, retro_event_id)
SELECT DISTINCT e.id as event_id,
                rre.retro_game_id,
                rre.retro_event_id
FROM ref_retro_events rre
INNER JOIN events e
    ON rre.plate_appearance_id = e.plate_appearance_id
    AND rre.event_sequence = e.event_sequence;
DROP TABLE ref_retro_events;
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS events cascade;
DROP TABLE IF EXISTS ref_events cascade;

67108864
134483968