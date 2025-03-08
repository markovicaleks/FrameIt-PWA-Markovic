import asyncHandler from 'express-async-handler';
import * as model from '../model/frameitModel.js';

export const getVideos = asyncHandler(async (req, res) => {
  res.status(200).json(await model.getVideos());
});

export const deleteVideo = asyncHandler(async (req, res) => {
  const { id } = req.params;
  res.status(202).json(await model.deleteVideo(id));
});

export const updateVideo = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { title } = req.body;
  const { description } = req.body;
  const { note } = req.body;

  res.status(202).json(await model.updateVideo(title, description, note, id));
});

export const postVideo = asyncHandler(async (req, res) => {
  const { title, description, note, place, city, country, continent, gps_latitude, gps_longitude, persons, timestamp, trip, video } = req.body;

  res.status(201).json(await model.postVideo(title, description, note, place, city, country, continent, gps_latitude, gps_longitude, persons, timestamp, trip, video));
});