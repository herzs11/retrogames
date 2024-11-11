-- +goose Up
-- +goose StatementBegin
CREATE TABLE pitch_sequences (
    plate_appearance_id int references plate_appearances(id),
    pitch_number smallint,
    pitch_id int references pitch_codes(id),
    UNIQUE(plate_appearance_id, pitch_number)
);

INSERT INTO pitch_sequences (plate_appearance_id, pitch_number, pitch_id)
select pitches.plate_appearance_id,
       pitches.pitch_number,
       pc.pitch_id
from (SELECT pitch_seqs.plate_appearance_id,
             i                                                 AS pitch_number,
             substring(pitch_seqs.pitch_sequence FROM i FOR 1) AS pitch_cd
      from (select e.plate_appearance_id,
                   translate(ev.pitch_seq_tx, '123.*+>N', '') as pitch_sequence
            from (SELECT plate_appearance_id,
                         MAX(event_sequence) AS last_event
                  FROM events
                  GROUP BY 1) max_event
                     INNER JOIN events e
                                ON max_event.plate_appearance_id = e.plate_appearance_id
                                    AND max_event.last_event = e.event_sequence
                     INNER JOIN ref_events re
                                ON e.id = re.event_id
                     INNER JOIN retrosheet.event ev
                                ON re.retro_game_id = ev.game_id
                                    AND re.retro_event_id = ev.event_id) pitch_seqs,
           generate_series(1, length(pitch_sequence)) i) pitches
         INNER JOIN ref_pitch_codes pc
                    ON pitches.pitch_cd = pc.retro_pitch_id
ORDER BY 1, 2;
-- +goose StatementEnd
-- +goose Down
DROP TABLE IF EXISTS pitch_sequences cascade;