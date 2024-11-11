-- +goose Up
-- +goose StatementBegin
CREATE TABLE ref_event_codes (
    id serial PRIMARY KEY,
    code varchar(1024)
)
CREATE TABLE event_codes (
    event_id int references events(id),
    event_code_id int references ref_event_codes(id),
    UNIQUE(event_id)
);
INSERT INTO ref_event_codes (code)
SELECT DISTINCT e.event_tx
FROM retrosheet.event e;

INSERT INTO event_codes (event_id, event_code_id)
SELECT DISTINCT re.event_id,
                ec.id as event_code_id
    FROM retrosheet.event e
         INNER JOIN ref_events re
                    ON e.game_id = re.retro_game_id
                        AND e.event_id = re.retro_event_id;
        INNER JOIN ref_event_codes ec
                    ON e.event_tx = ec.code;

-- +goose StatementEnd
-- +goose Down
DROP TABLE event_codes cascade;
DROP TABLE ref_event_codes cascade;