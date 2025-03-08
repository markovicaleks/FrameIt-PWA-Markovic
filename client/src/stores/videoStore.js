import { defineStore } from 'pinia';
import { ref } from 'vue';
import axios from 'axios';

export const useVideoStore = defineStore('videoStore', () => {
  // State
  const videos = ref([]);
  const errorMessage = ref(null); // Fehlernachricht hinzugefügt

  // Actions
  const fetchVideo = async () => {
    try {
      const { data } = await axios.get('http://localhost:3000/videos');
      if (JSON.stringify(videos.value) !== JSON.stringify(data)) {
        videos.value = Object.freeze([...data]); // Verhindert ungewollte Reaktivität
      }
    } catch (error) {
      errorMessage.value = error.message || 'Failed to fetch data';
    }
  };

  const deleteVideo = async (id) => {
    await axios.delete('http://localhost:3000/videos/' + id);
    await fetchVideo(); 
  };

  const patchVideo = async (id, title, description, note, place, city, country, continent) => {
    await axios.patch('http://localhost:3000/videos/' + id, { title, description, note, place, city, country, continent });
    await fetchVideo(); 
  };

  const postVideo = async (title, description, note, place, city, country, continent, gps_latitude, gps_longitude, persons, timestamp, trip, video) => {
    await axios.post('http://localhost:3000/videos', { title, description, note, place, city, country, continent, gps_latitude, gps_longitude, persons, timestamp, trip, video });
    await fetchVideo(); 
  };
  
  return {
    videos,
    errorMessage, 
    fetchVideo,
    deleteVideo,
    patchVideo,
    postVideo
  };
});