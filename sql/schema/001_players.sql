-- +goose Up
-- +goose StatementBegin
create table players
(
    id      serial primary key,
    first_name          varchar(1024),
    last_name           varchar(1024),
    nick_name       varchar(1024),
    date_of_birth       date,
    bats           char,
    throws         char,
    height         varchar(1024),
    weight         varchar(1024),
    hall_of_fame          boolean,
    bdb_people_id varchar(10)
);

create table ref_players
(
    player_id int references players(id),
    retro_player_id varchar(10),
    bbref_player_id varchar(10),
    bdb_people_id varchar(10)
);

with ref_pids AS (
INSERT INTO players(first_name, last_name, nick_name, date_of_birth, bats, throws, height, weight, hall_of_fame,bdb_people_id)
SELECT DISTINCT
    p.name_first as first_name,
    p.name_last as last_name,
    b.nickname as nick_name,
    MAKE_DATE(p.birth_year, p.birth_month, p.birth_day) as date_of_birth,
    p.bats,
    p.throws,
    p.height,
    p.weight,
    CASE WHEN hof.inducted = 'Y' THEN TRUE ELSE FALSE END as hall_of_fame,
    p.player_id as bdb_people_id
FROM baseballdatabank.people p
         LEFT JOIN retrosheet.bio b
                   ON p.retro_id = b.player_id
         LEFT JOIN baseballdatabank.hall_of_fame hof
                   ON p.player_id = hof.player_id
                       AND hof.inducted = 'Y'
WHERE p.retro_id IS NOT NULL
RETURNING id as player_id, bdb_people_id)
INSERT INTO ref_players (player_id, retro_player_id, bbref_player_id, bdb_people_id)
SELECT DISTINCT rp.player_id,
                rpl.retro_id as retro_player_id,
                rpl.bbref_id as bbref_player_id,
                rp.bdb_people_id
FROM ref_pids rp
INNER JOIN baseballdatabank.people rpl
ON rp.bdb_people_id = rpl.player_id;
ALTER TABLE players DROP COLUMN bdb_people_id;
-- +goose StatementEnd
-- +goose Down
drop table if exists players cascade;
drop table if exists ref_players cascade;
