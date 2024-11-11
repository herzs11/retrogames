-- +goose Up
-- +goose StatementBegin
CREATE TABLE game_results (
        id serial PRIMARY KEY,
        game_id int NOT NULL references games(id),
      length_in_outs                  smallint,
      completion_info            varchar(1024),
      forfeit_info               varchar(1024),
      protest_info               varchar(1024)
);
INSERT INTO game_results (game_id, length_in_outs, completion_info, forfeit_info, protest_info)
SELECT DISTINCT g.game_id,
       gl.length_in_outs,
       gl.completion_info,
       gl.forfeit_info,
       gl.protest_info
FROM retrosheet.gamelog gl
INNER JOIN ref_games g
ON CONCAT(gl.home_team,REPLACE(CAST(gl.date as varchar), '-',''),gl.double_header) = g.retro_game_id
WHERE gl.acquisition_info = 'Y';
-- +goose StatementEnd
-- +goose Down
DROP TABLE game_results cascade;