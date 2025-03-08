import express from 'express';
import { getVideos, deleteVideo, updateVideo, postVideo} from '../../controller/frameitController.js';

const router = express.Router();

router.get('/', getVideos);
router.delete('/:id', deleteVideo);
router.patch('/:id', updateVideo);
router.post('/', postVideo);

export default router;