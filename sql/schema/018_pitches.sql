-- +goose Up
-- +goose StatementBegin
CREATE TABLE pitch_codes (
    id serial PRIMARY KEY,
    description varchar(1024)
);

CREATE TABLE ref_pitch_codes (
    pitch_id int references pitch_codes(id),
    retro_pitch_id char
);
CREATE TEMP TABLE ref_pitch_types AS (
SELECT 'Automatic strike, usually for pitch timer violation' as description, 'A' as retro_pitch_id
UNION
SELECT 'Ball', 'B'
UNION
SELECT 'Called strike', 'C'
UNION
SELECT 'Foul', 'F'
UNION
SELECT 'Hit batter', 'H'
UNION
SELECT 'Intentional ball', 'I'
UNION
SELECT 'Strike (unknown type)', 'K'
UNION
SELECT 'Foul bunt', 'L'
UNION
SELECT 'Missed bunt attempt', 'M'
    UNION
SELECT 'foul tip on bunt', 'O'
    UNION
SELECT 'Pitchout', 'P'
    UNION
SELECT 'swinging on pitchout', 'Q'
    UNION
SELECT 'Foul ball on pitchout', 'R'
UNION
SELECT 'Swinging strike', 'S'
UNION
SELECT 'Foul tip', 'T'
UNION
SELECT 'Unknown or missed pitch', 'U'
    UNION
SELECT 'Called ball because pitcher went to his mouth or automatic ball on intentional walk or pitch timer violation', 'V'
UNION
SELECT 'Ball put into play by batter', 'X'
UNION
SELECT 'Ball put into play on pitchout', 'Y'
);
INSERT INTO pitch_codes (description)
SELECT DISTINCT description FROM ref_pitch_types;

INSERT INTO ref_pitch_codes (pitch_id, retro_pitch_id)
SELECT p.id as pitch_id,
       r.retro_pitch_id as retro_pitch_id
FROM ref_pitch_types r
INNER JOIN pitch_codes p
    ON r.description = p.description;

-- +goose StatementEnd
-- +goose Down
DROP TABLE IF EXISTS pitch_codes cascade;
DROP TABLE IF EXISTS ref_pitch_codes cascade;
