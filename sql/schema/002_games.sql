-- +goose Up
-- +goose StatementBegin
create table games
(
    id serial primary key,
    date                  date,
    game_number                  int not null,
    double_header            boolean,
    day_game                 boolean,
    away_team_id             char(3),
    home_team_id             char(3),
    park_id                  varchar(1024),
    attendance           integer,
    additional_info              varchar(1024),
    UNIQUE (date, game_number, home_team_id)
);

create table ref_games
(
    game_id int references games(id),
    retro_game_id char(12)
);

INSERT INTO games (date, game_number, double_header, day_game, away_team_id, home_team_id, park_id, attendance, additional_info)
SELECT DISTINCT
    gl.date,
    CAST(gl.double_header as int) as game_number,
    CASE WHEN gl.double_header = '0' THEN FALSE ELSE TRUE END as double_header,
    CASE WHEN gl.day_night = 'D' THEN TRUE ELSE FALSE END as day_game,
    gl.visiting_team as away_team_id,
    gl.home_team as home_team_id,
    gl.park_id,
    gl.attendance as attend_park_ct,
    gl.additional_info
FROM retrosheet.gamelog gl
WHERE gl.acquisition_info = 'Y'
ORDER BY gl.date, gl.visiting_team, gl.home_team, CAST(gl.double_header as int);
;

INSERT INTO ref_games (game_id, retro_game_id)
SELECT id as game_id,
       CONCAT(home_team_id, REPLACE(CAST(date as varchar), '-',''),CAST(game_number as char)) as retro_game_id
    FROM games;
-- +goose StatementEnd


-- +goose Down
drop table if exists games cascade;
drop table if exists ref_games cascade;