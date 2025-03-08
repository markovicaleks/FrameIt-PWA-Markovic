import { query } from '../../boilerplate/db/index.js';

export const getVideos = async () => {
  const { rows } = await query(
    'select * from videos',
  );
  return rows;
};

export const deleteVideo = async (id) => {
  const { rows } = await query(
    'delete from videos where id = $1 returning *',
    [id]
  );
  return rows;
};

export const updateVideo = async (title, description, note, id) => {
  const { rows } = await query(
    'update videos set title = $1, description = $2, note = $3 where id = $4 returning *',
    [title, description, note, id]
  );
  return rows;
};

export const postVideo = async (title, description, note, place, city, country, continent, gps_latitude, gps_longitude, persons, timestamp, trip, video) => {
  const { rows } = await query(
    'insert into videos (title, description, note, place, city, country, continent, gps_latitude, gps_longitude, persons, timestamp, trip, video) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) returning *',
    [title, description, note, place, city, country, continent, gps_latitude, gps_longitude, persons, timestamp, trip, video]
  );
  return rows;
};




