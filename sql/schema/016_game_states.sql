-- +goose Up

CREATE TABLE game_states (
    id serial PRIMARY KEY,
    away_score int,
    home_score int,
    outs int,
    balls int,
    strikes int
);
-- +goose StatementBegin
INSERT INTO game_states(away_score, home_score, outs, balls, strikes)
SELECT DISTINCT away_score_ct as away_score,
                home_score_ct as home_score,
                outs_ct as outs,
                balls_ct as balls,
                strikes_ct as strikes
    FROM retrosheet.event;
-- +goose StatementEnd

-- +goose Down
DROP TABLE game_states cascade;