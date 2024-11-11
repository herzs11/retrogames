-- +goose Up
-- +goose StatementBegin
CREATE TABLE plate_appearances (
                                   id serial PRIMARY KEY,
                                   game_id int NOT NULL references games(id),
                                   batter_id int NOT NULL references players(id),
                                   inning int NOT NULL,
                                   top boolean NOT NULL,
                                   truncated boolean,
                                   pa_count int,
                                   UNIQUE(game_id, batter_id, inning, pa_count)
    );

CREATE TABLE ref_plate_appearances (
                                        plate_appearance_id int NOT NULL references plate_appearances(id),
                                        retro_game_id char(12),
                                        retro_event_id int
     );

CREATE TEMP TABLE ref_pa AS (
                    SELECT DISTINCT g.game_id                                                                        as game_id,
                                    e.game_id as retro_game_id,
                                    e.bat_id as retro_bat_id,
                                    e.event_id as retro_event_id,
                                     p.player_id                                                                        as batter_id,
                                     e.inn_ct                                                                    as inning,
                                     NOT e.bat_home_id                                                           as top,
                                     e.inn_pa_ct,
                                     e.pa_trunc_fl as truncated,
                                     ROW_NUMBER()
                                     over (PARTITION BY e.game_id, e.inn_ct, e.bat_home_id, e.bat_id ORDER BY e.inn_pa_ct) as pa_count
                     FROM retrosheet.event e
                              INNER JOIN ref_games g
                                         ON e.game_id = g.retro_game_id
                              INNER JOIN ref_players p
                                         ON e.bat_id = p.retro_player_id
                     WHERE e.pa_new_fl = true
);
INSERT INTO plate_appearances (game_id, batter_id, inning, top, truncated, pa_count)
SELECT DISTINCT game_id, batter_id, inning, top, truncated, pa_count
FROM ref_pa ORDER BY 1,3,4,5;

INSERT INTO ref_plate_appearances (plate_appearance_id, retro_game_id, retro_event_id)
    SELECT DISTINCT pa.id as plate_appearance_id,
                    rpa.retro_game_id as retro_game_id,
                    rpa.retro_event_id as retro_event_id
    FROM ref_pa rpa
    INNER JOIN plate_appearances pa
        on rpa.batter_id = pa.batter_id
        and rpa.game_id = pa.game_id
        and rpa.inning = pa.inning
        and rpa.top = pa.top
        and rpa.pa_count = pa.pa_count
    ORDER BY 1;
DROP TABLE ref_pa;
-- +goose StatementEnd

-- +goose Down
DROP TABLE IF EXISTS plate_appearances cascade;
DROP TABLE IF EXISTS ref_plate_appearances cascade;
