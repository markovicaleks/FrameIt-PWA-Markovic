<template>
  <div class="reise-videos-wrapper">
    <div class="header">
      <h1>Reise-Videos</h1>
    </div>

    <!-- Mobile menu (only shows on small screens) -->
    <div class="mobile-menu">
      <q-btn 
        :icon="menuOpen ? 'close' : 'menu'" 
        flat 
        round 
        color="white" 
        @click="menuOpen = !menuOpen" 
        class="burger-button"
      />
      <div class="mobile-menu-items" v-if="menuOpen">
        <q-btn flat label="Alle Videos" color="white" class="menu-item" @click="filterCategory = null" />
        <q-btn flat label="Favoriten" color="white" class="menu-item" @click="filterCategory = 'favorites'" />
        <q-btn flat label="Nach Reise" color="white" class="menu-item" @click="filterCategory = 'trip'" />
        <q-btn flat label="Nach Land" color="white" class="menu-item" @click="filterCategory = 'country'" />
      </div>
    </div>

    <!-- Desktop menu (centered, hidden on small screens) -->
    <div class="menu-container">
      <div class="desktop-menu">
        <q-btn flat label="Alle Videos" color="white" class="menu-item" @click="filterCategory = null" />
        <q-btn flat label="Favoriten" color="white" class="menu-item" @click="filterCategory = 'favorites'" />
        <q-btn flat label="Nach Reise" color="white" class="menu-item" @click="filterCategory = 'trip'" />
        <q-btn flat label="Nach Land" color="white" class="menu-item" @click="filterCategory = 'country'" />
      </div>
    </div>

    <!-- Search and Add Button in the same line -->
    <div class="search-and-add-container">
      <q-input 
        v-model="searchText" 
        placeholder="Suchen..." 
        outlined 
        dense 
        dark
        class="search-input"
      >
        <template v-slot:prepend>
          <q-icon name="search" />
        </template>
      </q-input>
      
      <q-btn 
        icon="add" 
        label="Video hinzufügen"
        class="add-button-gradient" 
        @click="openAddDialog"
      />
    </div>

    <!-- Error message if data loading fails -->
    <div v-if="store.errorMessage" class="error-message">
      <q-banner class="bg-negative text-white">
        Fehler beim Laden der Daten: {{ store.errorMessage }}
        <template v-slot:action>
          <q-btn flat color="white" label="Wiederholen" @click="store.fetchVideo()" />
        </template>
      </q-banner>
    </div>

    <!-- Loading indicator -->
    <div v-if="loading" class="loading-state">
      <q-spinner size="3rem" color="white" />
      <p>Lade Videos...</p>
    </div>

    <!-- Video Cards Grid -->
    <div v-else class="video-grid">
      <q-card 
        v-for="(video, index) in filteredVideos" 
        :key="video.id"
        class="video-card"
        flat
        bordered
        dark
      >
        <!-- Video preview if available, otherwise thumbnail -->
        <div class="video-preview">
          <video 
            v-if="video.videoFile" 
            :src="video.videoFile" 
            class="video-file" 
            controls 
            muted
          ></video>
          <q-img
            v-else
            :src="video.thumbnail || 'https://placehold.co/400x225/2d2d2d/cccccc?text=Video'"
            class="video-thumbnail"
          >
            <div class="absolute-bottom text-subtitle2 bg-black bg-opacity-60 text-white p-2 text-center">
              {{  }}
            </div>
          </q-img>
        </div>
        
        <!-- Card content with fixed structure -->
        <q-card-section class="card-content">
          <!-- Always visible title -->
          <div class="video-title">{{ video.title || 'Unbenanntes Video' }}</div>
          
          <!-- Location information -->
          <div class="location">
            {{ formatLocation(video) }}
          </div>
          
          <!-- Metadata items - each on its own line, centered -->
          <div class="metadata flex flex-column items-center">
            <!-- Date item -->
            <div class="metadata-item q-my-1" v-if="video.timestamp">
              <q-icon name="event" size="xs" /> {{ formatDate(video.timestamp) }}
            </div>
            
            <!-- Persons item -->
            <div class="metadata-item q-my-1" v-if="video.persons">
              <q-icon name="people" size="xs" /> {{ video.persons }}
            </div>
            
            <!-- Trip item -->
            <div class="metadata-item q-my-1" v-if="video.trip">
              <q-icon name="card_travel" size="xs" /> {{ video.trip }}
            </div>
            
            <!-- GPS coordinates item with map link -->
            <div class="metadata-item q-my-1" v-if="video.gps_latitude || video.gps_longitude">
  <q-icon name="explore" size="xs" /> 
  <span>{{ formatCoordinates(video) }}</span>
  <q-btn 
    v-if="hasValidCoordinates(video)"
    dense
    flat
    label="Karte"
    icon="place" 
    size="xs" 
    color="blue-5"
    class="q-ml-xs"
    @click="openGoogleMaps(video)"
    title="Auf Karte anzeigen"
  />
</div>
          </div>
          
          <!-- Description -->
          <div class="description q-mt-md" v-if="video.description">
            {{ truncateText(video.description, 100) }}
          </div>

          <!-- Fixed note container with consistent height -->
          <div class="note-container">
            <div v-if="video.note" class="note">
              <div class="note-label"><q-icon name="sticky_note_2" size="xs" /> Notiz:</div>
              {{ truncateText(video.note, 80) }}
            </div>
          </div>
        </q-card-section>

        <q-card-actions align="center" class="q-pa-md">
          <q-btn 
            flat 
            :icon="video.favorite ? 'star' : 'star_border'" 
            :color="video.favorite ? 'amber' : 'white'" 
            @click="toggleFavorite(video)" 
            class="favorite-button" 
          />
          <q-btn flat icon="videocam" color="white" @click="openVideoRecorder(video.id)" />
          <q-btn flat icon="attach_file" color="white" @click="openFileUpload(video.id)" />
          <q-btn flat icon="edit" color="white" @click="openEditDialog(video)" />
          <q-btn flat icon="delete" color="white" @click="confirmDelete(video)" />
        </q-card-actions>
      </q-card>
    </div>

    <!-- Empty state when no videos -->
    <div v-if="!loading && filteredVideos.length === 0" class="empty-state">
      <q-icon name="videocam_off" size="4rem" color="grey-5" />
      <p v-if="searchText">Keine Videos gefunden für "{{ searchText }}"</p>
      <p v-else>Keine Videos gefunden</p>
      <q-btn color="primary" label="Video hinzufügen" @click="openAddDialog" class="mt-4 add-button-gradient" />
    </div>

    <!-- Hidden file input for file uploads -->
    <input 
      type="file" 
      ref="fileInput" 
      accept="video/*" 
      style="display: none" 
      @change="handleFileSelected"
    />

    <!-- Video Recorder Dialog -->
    <q-dialog v-model="videoRecorderOpen" persistent>
      <q-card class="video-recorder-dialog dark-dialog">
        <q-card-section class="q-pt-none">
          <div class="text-h6">Video aufnehmen</div>
          <div class="text-caption text-grey">Maximale Länge: 120 Sekunden</div>
        </q-card-section>
        
        <q-card-section class="video-container">
          <video ref="videoElement" autoplay class="video-feed"></video>
        </q-card-section>
        
        <q-card-section class="recording-timer q-py-sm" v-if="isRecording">
          <div class="text-center">
            <q-badge color="negative" class="q-px-md" v-if="recordingTime > 110">
              Aufnahme endet in {{ Math.max(0, 120 - recordingTime) }}s
            </q-badge>
            <q-badge color="primary" class="q-px-md" v-else>
              Aufnahme läuft: {{ recordingTime }}s
            </q-badge>
          </div>
        </q-card-section>
        
        <q-card-actions align="center" class="video-recorder-actions">
          <q-btn label="Abbrechen" color="grey-8" @click="closeVideoRecorder" />
          <q-btn 
            round 
            class="record-button" 
            :icon="isRecording ? 'stop' : 'fiber_manual_record'" 
            size="lg" 
            :color="isRecording ? 'negative' : 'negative'" 
            @click="toggleRecording" 
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Video Preview Dialog -->
    <q-dialog v-model="videoPreviewOpen" persistent>
      <q-card class="video-preview-dialog dark-dialog">
        <q-card-section class="q-pt-none">
          <div class="text-h6">Video Vorschau</div>
        </q-card-section>
        
        <q-card-section class="video-preview-container">
          <video ref="videoPreviewElement" controls class="video-preview-player"></video>
        </q-card-section>
        
        <q-card-actions align="right">
          <q-btn label="Verwerfen" color="grey-8" @click="discardRecording" />
          <q-btn label="Verwenden" color="positive" @click="saveRecording" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Map Dialog -->
    <!-- Improved Map Dialog -->
<!-- Improved Map Dialog -->
<q-dialog v-model="mapDialogOpen">
  <q-card class="map-dialog dark-dialog">
    <q-card-section class="q-pt-sm">
      <div class="text-h6">Standort: {{ mapLocationTitle }}</div>
      <div class="text-subtitle2 q-mt-xs">
        {{ mapCoordinates.lat ? mapCoordinates.lat.toFixed(6) + ', ' + mapCoordinates.lng.toFixed(6) : '' }}
      </div>
    </q-card-section>
    
    <q-card-section>
      <div class="map-container">
        <iframe 
          :src="mapEmbedUrl" 
          width="100%" 
          height="300" 
          style="border:0;" 
          allowfullscreen="" 
          loading="lazy"
        ></iframe>
      </div>
    </q-card-section>
    
    <q-card-actions align="right">
      <q-btn flat label="Schließen" color="grey-8" v-close-popup />
      <q-btn flat icon="open_in_new" label="In Karte öffnen" color="primary" @click="openExternalMap" />
    </q-card-actions>
  </q-card>
</q-dialog>

    <!-- Edit Video Dialog -->
    <q-dialog v-model="editDialogOpen" persistent>
      <q-card class="edit-dialog dark-dialog">
        <q-card-section>
          <div class="text-h6">{{ editMode === 'add' ? 'Neues Video' : 'Video bearbeiten' }}</div>
        </q-card-section>

        <q-card-section>
          <q-input v-model="editedVideo.title" label="Titel" outlined dense dark class="custom-input q-mb-md" />
          <q-input v-model="editedVideo.description" label="Beschreibung" type="textarea" outlined dense dark class="custom-input q-mb-md" />
          <q-input v-model="editedVideo.note" label="Notiz" outlined dense dark class="custom-input q-mb-md" />
          
          <!-- Only show these fields when adding a new video -->
          <template v-if="editMode === 'add'">
            <div class="row q-col-gutter-sm">
              <div class="col-12 col-sm-6">
                <q-input v-model="editedVideo.place" label="Ort" outlined dense dark class="custom-input" />
              </div>
              <div class="col-12 col-sm-6">
                <q-input v-model="editedVideo.city" label="Stadt" outlined dense dark class="custom-input" />
              </div>
            </div>
            
            <div class="row q-col-gutter-sm q-mt-md">
              <div class="col-12 col-sm-6">
                <q-input v-model="editedVideo.country" label="Land" outlined dense dark class="custom-input" />
              </div>
              <div class="col-12 col-sm-6">
                <q-input v-model="editedVideo.continent" label="Kontinent" outlined dense dark class="custom-input" />
              </div>
            </div>
            
            <div class="row q-col-gutter-sm q-mt-md">
              <div class="col-12 col-sm-6">
                <q-input v-model="editedVideo.gps_latitude" label="GPS Breitengrad" outlined dense dark class="custom-input" />
              </div>
              <div class="col-12 col-sm-6">
                <q-input v-model="editedVideo.gps_longitude" label="GPS Längengrad" outlined dense dark class="custom-input" />
              </div>
            </div>
            
            <div class="row q-col-gutter-sm q-mt-md">
              <div class="col-12 col-sm-6">
                <q-input v-model="personsString" label="Personen" hint="Komma-getrennte Liste von Personen" outlined dense dark class="custom-input" />
              </div>
              <div class="col-12 col-sm-6">
                <q-input v-model="editedVideo.trip" label="Reise" outlined dense dark class="custom-input" />
              </div>
            </div>
            
            <q-input 
              v-model="editedVideo.timestamp" 
              label="Datum & Zeit" 
              outlined 
              dense 
              dark
              class="custom-input q-mt-md"
              type="datetime-local" 
            />
          </template>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Abbrechen" color="grey-8" v-close-popup @click="editDialogOpen = false" />
          <q-btn flat label="Speichern" class="save-button-gradient" @click="saveVideo" />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- Delete Confirmation Dialog -->
    <q-dialog v-model="deleteDialogOpen" persistent>
      <q-card class="dark-dialog">
        <q-card-section class="row items-center">
          <q-avatar icon="delete" color="negative" text-color="white" />
          <span class="q-ml-sm">Möchten Sie das Video "{{ deleteVideo?.title || 'Unbenannt' }}" wirklich löschen?</span>
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="Abbrechen" color="grey-8" v-close-popup />
          <q-btn flat label="Löschen" color="negative" @click="confirmDeleteAction" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useVideoStore } from '../stores/videoStore.js';
import { useQuasar } from 'quasar';

const store = useVideoStore();
const $q = useQuasar();

// UI state
const videoRecorderOpen = ref(false);
const videoPreviewOpen = ref(false);
const menuOpen = ref(false);
const loading = ref(true);
const searchText = ref('');
const filterCategory = ref(null);
const currentVideoId = ref(null);
const editDialogOpen = ref(false);
const deleteDialogOpen = ref(false);
const editMode = ref('edit'); // 'edit' or 'add'
const deleteVideo = ref(null);
const isRecording = ref(false);
const recordingTime = ref(0);
const fileInput = ref(null);
const mapDialogOpen = ref(false);
const mapLocationTitle = ref('');
const mapCoordinates = ref({ lat: null, lng: null });

// DOM references
const videoElement = ref(null);
const videoPreviewElement = ref(null);
let stream = null;
let mediaRecorder = null;
let recordedChunks = [];
let recordingTimer = null;

// Form data
const editedVideo = ref({
  id: null,
  title: '',
  description: '',
  note: '',
  place: '',
  city: '',
  country: '',
  continent: '',
  gps_latitude: '',
  gps_longitude: '',
  persons: [], // Changed from string to array
  timestamp: '',
  trip: '',
  videoFile: null,
  favorite: false, // Added favorite property
});

// Reset form function
const resetForm = () => {
  editedVideo.value = {
    id: null,
    title: '',
    description: '',
    note: '',
    place: '',
    city: '',
    country: '',
    continent: '',
    gps_latitude: '',
    gps_longitude: '',
    persons: [], // Changed from string to array
    timestamp: '',
    trip: '',
    videoFile: null,
    favorite: false, // Added favorite property
  };
};

// Toggle favorite function
const toggleFavorite = async (video) => {
  try {
    // Toggle the favorite status in the local state first for immediate UI update
    video.favorite = !video.favorite;
    
    // Force the UI to update immediately by creating a new reference
    store.videos = [...store.videos];
    
    // Save favorites to localStorage
    saveFavoritesToLocalStorage();
    
    // Show notification
    $q.notify({
      type: 'positive',
      message: video.favorite 
        ? `"${video.title || 'Video'}" zu Favoriten hinzugefügt` 
        : `"${video.title || 'Video'}" aus Favoriten entfernt`,
      timeout: 2000
    });
    
  } catch (error) {
    // Revert the change if there was an error
    video.favorite = !video.favorite;
    $q.notify({
      type: 'negative',
      message: 'Fehler beim Aktualisieren der Favoriten',
      timeout: 2000
    });
  }
};

// Save favorites to localStorage
const saveFavoritesToLocalStorage = () => {
  // Create an object mapping video IDs to favorite status
  const favorites = {};
  store.videos.forEach(video => {
    if (video.favorite) {
      favorites[video.id] = true;
    }
  });
  
  // Save to localStorage
  localStorage.setItem('videoFavorites', JSON.stringify(favorites));
};

// Load favorites from localStorage
const loadFavoritesFromLocalStorage = () => {
  try {
    const favorites = JSON.parse(localStorage.getItem('videoFavorites')) || {};
    
    // Apply favorite status to videos
    store.videos.forEach(video => {
      if (favorites[video.id]) {
        video.favorite = true;
      }
    });
    
    // Create a new reference to ensure reactivity
    store.videos = [...store.videos];
  } catch (error) {
    console.error('Error loading favorites from localStorage:', error);
  }
};

// Computed filtered videos
const filteredVideos = computed(() => {
  if (!store.videos || store.videos.length === 0) return [];

  let result = [...store.videos];

  // Text search filter
  if (searchText.value.trim()) {
    const search = searchText.value.toLowerCase();
    result = result.filter(
      (video) =>
        (video.title && video.title.toLowerCase().includes(search)) ||
        (video.place && video.place.toLowerCase().includes(search)) ||
        (video.city && video.city.toLowerCase().includes(search)) ||
        (video.country && video.country.toLowerCase().includes(search)) ||
        // Handle persons correctly as an array
        (Array.isArray(video.persons) &&
          video.persons.some((person) => person.toLowerCase().includes(search))) ||
        (video.trip && video.trip.toLowerCase().includes(search)),
    );
  }

  // Category filter
  if (filterCategory.value === 'favorites') {
    // Filter to show only favorite videos
    result = result.filter((video) => video.favorite === true);
  } else if (filterCategory.value === 'trip') {
    // Group by trip (could be expanded to show grouped UI)
    result = result.filter((video) => video.trip && video.trip.trim() !== '');
    result.sort((a, b) => (a.trip || '').localeCompare(b.trip || ''));
  } else if (filterCategory.value === 'country') {
    // Group by country
    result = result.filter((video) => video.country && video.country.trim() !== '');
    result.sort((a, b) => (a.country || '').localeCompare(b.country || ''));
  }
  // 'favorites' filter would be implemented here when that data is available

  return result;
});

// Lifecycle hooks
onMounted(async () => {
  try {
    await store.fetchVideo();
    
    // Load videos from IndexedDB immediately rather than with setTimeout
    await loadVideosFromIndexedDB();

    loadFavoritesFromLocalStorage();
  } finally {
    loading.value = false;
  }

  // Close menu when window is resized to desktop
  window.addEventListener('resize', () => {
    if (window.innerWidth > 768) {
      menuOpen.value = false;
    }
  });
});

// New function to load videos from IndexedDB and update UI
const loadVideosFromIndexedDB = async () => {
  try {
    // Create a copy of the videos array to modify
    const updatedVideos = [...store.videos];
    let videosUpdated = false;
    
    // Process each video
    for (const [index, video] of updatedVideos.entries()) {
      try {
        const videoBlob = await videoDb.getVideo(video.id);
        if (videoBlob) {
          const videoUrl = URL.createObjectURL(videoBlob);
          // Update the video with the file URL
          updatedVideos[index] = { ...video, videoFile: videoUrl };
          videosUpdated = true;
        }
      } catch (error) {
        console.warn(`Konnte Video ${video.id} nicht wiederherstellen:`, error);
      }
    }
    
    // Only update the store if changes were made to trigger reactivity
    if (videosUpdated) {
      // Update the store with the new array to ensure reactivity
      store.videos = updatedVideos;
    }
  } catch (error) {
    console.error('Fehler beim Laden der Videos aus IndexedDB:', error);
  }
};

// Clean up on unmount
const beforeUnmount = () => {
  closeVideoRecorder();
};

// Watch for store error changes
watch(
  () => store.errorMessage,
  (newVal) => {
    if (newVal) {
      loading.value = false;
    }
  },
);

// Format helpers
const formatDate = (timestamp) => {
  if (!timestamp) return 'Kein Datum';

  try {
    const date = new Date(timestamp);
    return new Intl.DateTimeFormat('de-DE', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }).format(date);
  } catch (e) {
    return 'Ungültiges Datum';
  }
};

const formatCoordinates = (video) => {
  if (!video.gps_latitude && !video.gps_longitude) return 'Keine GPS-Daten';

  const lat = video.gps_latitude ? parseFloat(video.gps_latitude).toFixed(4) : 'N/A';
  const lng = video.gps_longitude ? parseFloat(video.gps_longitude).toFixed(4) : 'N/A';

  return `${lat}, ${lng}`;
};

const hasValidCoordinates = (video) => {
  return video.gps_latitude && video.gps_longitude && 
         !isNaN(parseFloat(video.gps_latitude)) && 
         !isNaN(parseFloat(video.gps_longitude));
};

const openGoogleMaps = (video) => {
  if (!hasValidCoordinates(video)) return;
  
  // Instead of directly opening Google Maps, show the map dialog
  showMapDialog(video);
};

// Alternative approach with a map dialog
const showMapDialog = (video) => {
  if (!hasValidCoordinates(video)) return;
  
  mapCoordinates.value = {
    lat: parseFloat(video.gps_latitude),
    lng: parseFloat(video.gps_longitude)
  };
  
  // Set location title with more context
  mapLocationTitle.value = video.title 
    ? `${video.title} (${formatLocation(video)})` 
    : formatLocation(video);
  
  // Open dialog
  mapDialogOpen.value = true;
};

const mapEmbedUrl = computed(() => {
  if (!mapCoordinates.value.lat || !mapCoordinates.value.lng) return '';
  
  // Using OpenStreetMap instead of Google Maps API (no key required)
  return `https://www.openstreetmap.org/export/embed.html?bbox=${mapCoordinates.value.lng-0.01}%2C${mapCoordinates.value.lat-0.01}%2C${mapCoordinates.value.lng+0.01}%2C${mapCoordinates.value.lat+0.01}&layer=mapnik&marker=${mapCoordinates.value.lat}%2C${mapCoordinates.value.lng}`;
});

// Update the external map function to work with both Google Maps and OpenStreetMap
const openExternalMap = () => {
  if (!mapCoordinates.value.lat || !mapCoordinates.value.lng) return;
  
  // Default to Google Maps
  const url = `https://www.google.com/maps?q=${mapCoordinates.value.lat},${mapCoordinates.value.lng}`;
  window.open(url, '_blank');
  
  // Close dialog
  mapDialogOpen.value = false;
};

const formatLocation = (video) => {
  const parts = [video.place, video.city, video.country, video.continent].filter(
    (part) => part && part.trim() !== '',
  );

  return parts.length > 0 ? parts.join(', ') : 'Keine Ortsangabe';
};

const truncateText = (text, maxLength) => {
  if (!text) return '';
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength) + '...';
};

// File upload functionality
const openFileUpload = (videoId) => {
  currentVideoId.value = videoId;
  // Trigger the hidden file input
  fileInput.value.click();
};

const handleFileSelected = async (event) => {
  try {
    const file = event.target.files[0];
    if (!file) return;

    // Check if file is a video
    if (!file.type.startsWith('video/')) {
      $q.notify({
        type: 'negative',
        message: 'Bitte wählen Sie eine gültige Videodatei aus',
      });
      fileInput.value.value = ''; // Clear the input
      return;
    }

    // Create video element to check duration
    const tempVideo = document.createElement('video');
    tempVideo.preload = 'metadata';

    tempVideo.onloadedmetadata = async () => {
      URL.revokeObjectURL(tempVideo.src);

      // Check if video is longer than 120 seconds
      if (tempVideo.duration > 120) {
        $q.notify({
          type: 'negative',
          message: 'Das Video darf nicht länger als 120 Sekunden sein',
        });
        fileInput.value.value = ''; // Clear the input
        return;
      }

      // Valid video, create URL
      const videoUrl = URL.createObjectURL(file);

      // Update the video in the store
      if (currentVideoId.value) {
        // Find the video in store and update it
        const videoIndex = store.videos.findIndex((v) => v.id === currentVideoId.value);
        if (videoIndex !== -1) {
          // Create a new array to trigger reactivity
          const updatedVideos = [...store.videos];
          updatedVideos[videoIndex] = { 
            ...updatedVideos[videoIndex], 
            videoFile: videoUrl 
          };
          // Update the store with the new array
          store.videos = updatedVideos;
          
          // Save to IndexedDB
          await videoDb.saveVideo(currentVideoId.value, file);

          $q.notify({
            type: 'positive',
            message: 'Video erfolgreich aktualisiert',
          });
        }
      }

      // Clear the file input for future use
      fileInput.value.value = '';
    };

    tempVideo.src = URL.createObjectURL(file);
  } catch (error) {
    console.error('Fehler beim Hochladen des Videos:', error);
    $q.notify({
      type: 'negative',
      message: 'Fehler beim Hochladen des Videos',
    });
    fileInput.value.value = ''; // Clear the input
  }
};

const requestMediaPermissions = async () => {
  try {
    // First try just requesting permission without actually accessing the stream
    await navigator.permissions.query({ name: 'camera' });
    await navigator.permissions.query({ name: 'microphone' });
    return true;
  } catch (err) {
    console.log('Permissions API not supported, will try direct access');
    // Fallback for browsers that don't support the Permissions API
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
      // Immediately stop all tracks to release the devices
      stream.getTracks().forEach((track) => track.stop());
      return true;
    } catch (err) {
      return false;
    }
  }
};

const openVideoRecorder = async (videoId) => {
  currentVideoId.value = videoId;

  // Check if permissions are already granted or can be granted
  const hasPermission = await requestMediaPermissions();

  if (!hasPermission) {
    $q.notify({
      type: 'negative',
      message:
        'Bitte erlauben Sie den Zugriff auf Kamera und Mikrofon in Ihren Browser-Einstellungen',
      timeout: 5000,
      actions: [{ label: 'Verstanden', color: 'white' }],
    });
    return;
  }

  videoRecorderOpen.value = true;

  try {
    stream = await navigator.mediaDevices.getUserMedia({
      video: true,
      audio: true,
    });
    videoElement.value.srcObject = stream;
  } catch (err) {
    console.error('Video konnte nicht gestartet werden:', err);

    let errorMessage = 'Video konnte nicht gestartet werden: ';

    if (err.name === 'NotAllowedError' || err.name === 'PermissionDeniedError') {
      errorMessage += 'Zugriff verweigert. Bitte erlauben Sie den Zugriff auf Kamera und Mikrofon.';
    } else if (err.name === 'NotFoundError' || err.name === 'DevicesNotFoundError') {
      errorMessage += 'Keine Kamera oder Mikrofon gefunden.';
    } else if (err.name === 'NotReadableError' || err.name === 'TrackStartError') {
      errorMessage += 'Kamera oder Mikrofon wird bereits von einer anderen Anwendung verwendet.';
    } else {
      errorMessage += err.message;
    }

    $q.notify({
      type: 'negative',
      message: errorMessage,
      timeout: 5000,
    });

    closeVideoRecorder();
  }
};

const toggleRecording = () => {
  if (isRecording.value) {
    stopRecording();
  } else {
    startRecording();
  }
};

const startRecording = () => {
  if (!stream) return;

  recordedChunks = [];
  const options = { mimeType: 'video/webm; codecs=vp9' };

  try {
    mediaRecorder = new MediaRecorder(stream, options);
  } catch (e) {
    console.error('MediaRecorder is not supported by this browser.');
    return;
  }

  mediaRecorder.ondataavailable = handleDataAvailable;
  mediaRecorder.onstop = handleRecordingStop;

  // Start recording
  mediaRecorder.start(100); // Collect data in chunks of 100ms
  isRecording.value = true;
  recordingTime.value = 0;

  // Set up a timer to update recording time
  recordingTimer = setInterval(() => {
    recordingTime.value += 1;

    // Auto-stop recording after 120 seconds
    if (recordingTime.value >= 120) {
      stopRecording();
    }
  }, 1000);
};

const stopRecording = () => {
  if (!mediaRecorder || mediaRecorder.state === 'inactive') return;

  mediaRecorder.stop();
  clearInterval(recordingTimer);
  isRecording.value = false;
};

const handleDataAvailable = (event) => {
  if (event.data && event.data.size > 0) {
    recordedChunks.push(event.data);
  }
};

const handleRecordingStop = () => {
  // Show video preview
  const videoBlob = new Blob(recordedChunks, { type: 'video/webm' });
  const videoUrl = URL.createObjectURL(videoBlob);

  // Close recorder and show preview
  videoRecorderOpen.value = false;
  videoPreviewOpen.value = true;

  // Set the preview video source
  setTimeout(() => {
    if (videoPreviewElement.value) {
      videoPreviewElement.value.src = videoUrl;
      videoPreviewElement.value.play();
    }
  }, 100);
};

const saveRecording = async () => {
  try {
    // Create a blob from the recorded chunks
    const videoBlob = new Blob(recordedChunks, { type: 'video/webm' });
    const videoUrl = URL.createObjectURL(videoBlob);

    // Attach to the edited video or update an existing video
    if (currentVideoId.value) {
      // Find the video in store and update it
      const videoIndex = store.videos.findIndex((v) => v.id === currentVideoId.value);
      if (videoIndex !== -1) {
        // Create a new array to trigger reactivity
        const updatedVideos = [...store.videos];
        updatedVideos[videoIndex] = { 
          ...updatedVideos[videoIndex], 
          videoFile: videoUrl 
        };
        // Update the store with the new array
        store.videos = updatedVideos;
        
        // Save video to IndexedDB
        await videoDb.saveVideo(currentVideoId.value, videoBlob);
        
        $q.notify({
          type: 'positive',
          message: 'Video erfolgreich aktualisiert',
        });
      }
    }

    // Close preview
    videoPreviewOpen.value = false;
    clearRecordingData();
  } catch (error) {
    console.error('Fehler beim Speichern des Videos:', error);
    $q.notify({
      type: 'negative',
      message: 'Fehler beim Speichern des Videos',
    });
  }
};

const discardRecording = () => {
  videoPreviewOpen.value = false;
  clearRecordingData();
};

const clearRecordingData = () => {
  recordedChunks = [];
  if (videoPreviewElement.value) {
    videoPreviewElement.value.src = '';
  }
};

const closeVideoRecorder = () => {
  videoRecorderOpen.value = false;
  isRecording.value = false;

  // Clear any running timers
  if (recordingTimer) {
    clearInterval(recordingTimer);
    recordingTimer = null;
  }

  // Stop the media recorder if active
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    try {
      mediaRecorder.stop();
    } catch (e) {
      console.warn('Error stopping mediaRecorder:', e);
    }
    mediaRecorder = null;
  }

  // Stop all tracks and release media resources
  if (stream) {
    try {
      const tracks = stream.getTracks();
      tracks.forEach((track) => {
        track.stop();
        stream.removeTrack(track);
      });
    } catch (e) {
      console.warn('Error stopping media tracks:', e);
    }
    stream = null;
  }

  // Clear the video element source
  if (videoElement.value) {
    videoElement.value.srcObject = null;
  }

  // Force garbage collection hint (though JS engines decide when to actually do it)
  if (global.gc) {
    global.gc();
  }
};

// CRUD operations
const openAddDialog = () => {
  resetForm();
  editMode.value = 'add';
  editDialogOpen.value = true;
};

const openEditDialog = (videoData) => {
  // For edit mode, we now handle both minimal editing and full data
  editedVideo.value = {
    id: videoData.id,
    title: videoData.title || '',
    description: videoData.description || '',
    note: videoData.note || '',
    place: videoData.place || '',
    city: videoData.city || '',
    country: videoData.country || '',
    continent: videoData.continent || '',
    gps_latitude: videoData.gps_latitude || '',
    gps_longitude: videoData.gps_longitude || '',
    // Ensure persons is always an array
    persons: Array.isArray(videoData.persons)
      ? [...videoData.persons]
      : videoData.persons
      ? String(videoData.persons)
          .split(',')
          .map((p) => p.trim())
      : [],
    timestamp: videoData.timestamp || '',
    trip: videoData.trip || '',
    videoFile: videoData.videoFile || null,
    favorite: videoData.favorite || false, // Added favorite property
  };
  editMode.value = 'edit';
  editDialogOpen.value = true;
};

const saveVideo = async () => {
  try {
    if (editMode.value === 'add') {
      await store.postVideo(
        editedVideo.value.title,
        editedVideo.value.description,
        editedVideo.value.note,
        editedVideo.value.place,
        editedVideo.value.city,
        editedVideo.value.country,
        editedVideo.value.continent,
        editedVideo.value.gps_latitude,
        editedVideo.value.gps_longitude,
        editedVideo.value.persons, // Now properly passed as an array
        editedVideo.value.timestamp,
        editedVideo.value.trip,
        null, // No video file from add dialog
        editedVideo.value.favorite // Include favorite status
      );
      $q.notify({
        type: 'positive',
        message: 'Video erfolgreich hinzugefügt',
      });
    } else {
      // In edit mode, only update the allowed fields (title, description, note)
      // Also include favorite status in updates
      await store.patchVideo(
        editedVideo.value.id,
        editedVideo.value.title,
        editedVideo.value.description,
        editedVideo.value.note,
        editedVideo.value.favorite // Include favorite status in the patch
      );
      $q.notify({
        type: 'positive',
        message: 'Video erfolgreich aktualisiert',
      });
    }
    editDialogOpen.value = false;

    await loadVideosFromIndexedDB();

    loadFavoritesFromLocalStorage();

  } catch (error) {
    console.error('Error saving video:', error);
    $q.notify({
      type: 'negative',
      message: 'Fehler beim Speichern: ' + (error.message || 'Unbekannter Fehler'),
    });
  }
};

const confirmDelete = (videoData) => {
  deleteVideo.value = videoData;
  deleteDialogOpen.value = true;
};

const confirmDeleteAction = async () => {
  if (!deleteVideo.value || !deleteVideo.value.id) return;

  try {
    await store.deleteVideo(deleteVideo.value.id);
    
    // Also delete from IndexedDB
    await videoDb.deleteVideo(deleteVideo.value.id);
    
    deleteDialogOpen.value = false;
    $q.notify({
      type: 'positive',
      message: 'Video erfolgreich gelöscht',
    });

    await loadVideosFromIndexedDB();

    loadFavoritesFromLocalStorage();

  } catch (error) {
    console.error('Error deleting video:', error);
    $q.notify({
      type: 'negative',
      message: 'Fehler beim Löschen: ' + (error.message || 'Unbekannter Fehler'),
    });
  }
};

const personsString = computed({
  get: () => editedVideo.value.persons.join(', '),
  set: (value) => {
    editedVideo.value.persons = value
      .split(',')
      .map((item) => item.trim())
      .filter((item) => item !== '');
  },
});

const videoDb = {
  dbName: 'reiseVideosDb',
  dbVersion: 1,
  videoStore: 'videoFiles',
  
  // Open database connection
  openDb() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(this.dbName, this.dbVersion);
      
      request.onerror = (event) => reject(`IndexedDB error: ${event.target.error}`);
      
      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        // Create object store if it doesn't exist
        if (!db.objectStoreNames.contains(this.videoStore)) {
          db.createObjectStore(this.videoStore);
        }
      };
      
      request.onsuccess = (event) => resolve(event.target.result);
    });
  },
  
  // Save video blob
  async saveVideo(videoId, videoBlob) {
    try {
      const db = await this.openDb();
      return new Promise((resolve, reject) => {
        const transaction = db.transaction([this.videoStore], 'readwrite');
        const store = transaction.objectStore(this.videoStore);
        const request = store.put(videoBlob, videoId);
        
        request.onerror = (event) => reject(`Save error: ${event.target.error}`);
        request.onsuccess = () => resolve(true);
        
        // Close the db when the transaction is done
        transaction.oncomplete = () => db.close();
      });
    } catch (error) {
      console.error('Error saving video to IndexedDB:', error);
      throw error;
    }
  },
  
  // Get video blob
  async getVideo(videoId) {
    try {
      const db = await this.openDb();
      return new Promise((resolve, reject) => {
        const transaction = db.transaction([this.videoStore], 'readonly');
        const store = transaction.objectStore(this.videoStore);
        const request = store.get(videoId);
        
        request.onerror = (event) => reject(`Get error: ${event.target.error}`);
        request.onsuccess = (event) => resolve(event.target.result);
        
        // Close the db when the transaction is done
        transaction.oncomplete = () => db.close();
      });
    } catch (error) {
      console.error('Error getting video from IndexedDB:', error);
      return null;
    }
  },
  
  // Delete video
  async deleteVideo(videoId) {
    try {
      const db = await this.openDb();
      return new Promise((resolve, reject) => {
        const transaction = db.transaction([this.videoStore], 'readwrite');
        const store = transaction.objectStore(this.videoStore);
        const request = store.delete(videoId);
        
        request.onerror = (event) => reject(`Delete error: ${event.target.error}`);
        request.onsuccess = () => resolve(true);
        
        // Close the db when the transaction is done
        transaction.oncomplete = () => db.close();
      });
    } catch (error) {
      console.error('Error deleting video from IndexedDB:', error);
      throw error;
    }
  }
};
</script>

<style scoped>
.reise-videos-wrapper {
  background-color: #1c1c1c;
  min-height: 100vh;
  width: 100%;
  color: white;
  position: relative;
  overflow-x: hidden;
  padding: 1.5rem;
  font-family: 'Open Sans', sans-serif;
  text-align: center;
}

/* Header styles - Centered, no add button */
.header {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 1.5rem;
  width: 100%;
}

.header h1 {
  font-size: 2.2rem;
  font-weight: 700;
  color: white;
  margin: 0;
}

/* Menu and filters - Properly centered */
.menu-container {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 1.5rem;
}

.desktop-menu {
  display: flex;
  gap: 1rem;
  margin-bottom: 1.5rem;
  justify-content: center;
  width: 100%;
  max-width: 600px;
}

.mobile-menu {
  display: none;
  position: relative;
  margin-bottom: 1.5rem;
  text-align: center;
  width: 100%;
}

.mobile-menu-items {
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  background-color: #2d2d2d;
  border-radius: 12px;
  padding: 0.5rem;
  z-index: 100;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  width: 200px;
}

.menu-item {
  border-radius: 8px;
  font-weight: 600;
  text-align: center;
  width: 100%;
}

/* Add these styles to your CSS */
.map-container {
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.map-dialog {
  width: 90vw;
  max-width: 600px;
}

@media (max-width: 600px) {
  .map-dialog {
    width: 95vw;
  }
}

.menu-item:hover {
  background-color: #3a3a3a;
}

/* Search and Add button container */
.search-and-add-container {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  width: 100%;
  max-width: 800px;
  margin: 0 auto 1.5rem;
}

/* Search styles - adjusted for new container */
.search-input {
  flex: 1;
  max-width: 500px;
}

.search-input ::v-deep .q-field__control {
  background-color: #2d2d2d;
  border: 2px solid #3a3a3a;
  border-radius: 12px;
}

/* Loading styles */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 300px;
  color: #cccccc;
  text-align: center;
}

/* Video grid styles - fixed to 4 cards per row */
.video-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.5rem;
  justify-items: center;
  max-width: 1400px;
  margin: 0 auto;
}

.video-card {
  background-color: #2d2d2d;
  border-radius: 12px;
  border-color: #3a3a3a;
  overflow: hidden;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  text-align: center;
  width: 100%;
  display: flex;
  flex-direction: column;
  position: relative;
  height: 100%; /* Ensure consistent height */
}

.video-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.3);
}

/* Video title - always visible */
.video-title {
  font-size: 1.4rem; /* Increased from 1.1rem */
  font-weight: 700; /* Increased from 600 for more emphasis */
  margin: 0.8rem 0;
  text-align: center;
}

/* Standardize card content structure */
.video-preview {
  position: relative;
  width: 100%;
  height: 0;
  padding-bottom: 56.25%; /* 16:9 aspect ratio */
  overflow: hidden;
}

.video-file,
.video-thumbnail {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* Card content - modified structure for fixed note position */
.card-content {
  padding: 1rem;
  display: flex;
  flex-direction: column;
  flex: 1;
  position: relative;
}

.location {
  font-size: 1rem; /* Decreased from 1.2rem */
  font-weight: 600; /* Decreased from 700 */
  margin-bottom: 0.5rem;
  text-align: center;
}

.metadata {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 0.8rem;
  color: #cccccc;
  font-size: 0.9rem;
}

.metadata-item {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.3rem;
  margin: 0.25rem 0;
}

.description {
  color: #aaaaaa;
  font-size: 0.95rem;
  line-height: 1.4;
  text-align: center;
  margin-bottom: 1rem;
}

/* Fixed note container */
.note-container {
  height: 80px; /* Fixed height for note section */
  width: 100%;
  margin-top: auto; /* Push to bottom of flexible space */
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 0; /* No margin needed as it's fixed height */
}

.note {
  color: #c0c0c0;
  font-size: 0.9rem;
  line-height: 1.3;
  text-align: center;
  background-color: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  padding: 0.5rem;
  width: 100%;
}

.note-label {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.3rem;
  margin-bottom: 0.3rem;
  font-weight: 600;
  color: #d0d0d0;
}

/* Action buttons styling */
.video-card .q-card-actions {
  padding: 0.75rem !important;
  margin-top: 0;
}

/* Empty state styles */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 300px;
  color: #cccccc;
  text-align: center;
}

/* Dialog styles */
.dark-dialog {
  background-color: #1c1c1c;
  border-radius: 16px;
  color: white;
  text-align: center;
}

.video-recorder-dialog,
.video-preview-dialog,
.edit-dialog {
  min-width: 350px;
  max-width: 90vw;
  text-align: center;
}

.video-feed,
.video-preview-player {
  width: 100%;
  border-radius: 12px;
  background-color: #2d2d2d;
  margin: 0 auto;
}

.record-button {
  min-height: 60px;
  min-width: 60px;
  margin: 0 auto;
}

/* Custom Input Styles */
.custom-input ::v-deep .q-field__control {
  background-color: #2d2d2d;
  border: 2px solid #3a3a3a;
  border-radius: 12px;
  height: 56px;
  margin: 0 auto;
}

.custom-input ::v-deep .q-field__control:hover {
  border-color: #6ad431;
}

.custom-input ::v-deep .q-field__native,
.custom-input ::v-deep .q-field__prefix,
.custom-input ::v-deep .q-field__suffix {
  color: white;
  font-size: 1.1rem;
  text-align: left;
}

.custom-input ::v-deep .q-field__label {
  color: #aaaaaa;
  font-size: 1rem;
  text-align: center;
}

/* Gradient Button Styles */
.add-button-gradient,
.save-button-gradient {
  background: linear-gradient(to right, #ffc107, #6ad431);
  color: white;
  font-weight: 600;
  border-radius: 12px;
  transition: all 0.3s ease;
}

.add-button-gradient:hover,
.save-button-gradient:hover {
  opacity: 0.9;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(106, 212, 49, 0.3);
}

/* Error message styles */
.error-message {
  margin-bottom: 1.5rem;
}

/* Responsive styles - updated for search and add button */
@media (max-width: 1200px) {
  .video-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 900px) {
  .video-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .search-and-add-container {
    flex-direction: column;
    gap: 0.8rem;
  }
  
  .search-input {
    width: 100%;
    max-width: none;
  }
  
  .add-button-gradient {
    width: 100%;
  }
}

@media (max-width: 600px) {
  .video-grid {
    grid-template-columns: 1fr;
  }
  
  .desktop-menu {
    display: none;
  }
  
  .mobile-menu {
    display: block;
  }
  
  .header h1 {
    font-size: 1.8rem;
  }
}

/* Landing Page Styles */
.landing-page-container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 40px 20px;
  background-color: #0F1014;
  font-family: "Heebo", sans-serif;
  position: relative;
  overflow: hidden;
  text-align: center;
}

.background-pattern {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: radial-gradient(circle at 10% 20%, rgba(106, 212, 49, 0.08) 0%, transparent 30%),
              radial-gradient(circle at 90% 30%, rgba(10, 205, 254, 0.08) 0%, transparent 30%),
              radial-gradient(circle at 50% 70%, rgba(254, 68, 125, 0.08) 0%, transparent 30%),
              radial-gradient(circle at 20% 90%, rgba(255, 193, 7, 0.08) 0%, transparent 30%);
  z-index: 1;
}

.landing-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  max-width: 900px;
  position: relative;
  z-index: 2;
  text-align: center;
}

.brand-name {
  color: white;
  font-style: italic;
  font-size: 4rem;
  margin: 0 0 100px 0;
  font-weight: 700;
  letter-spacing: 2px;
  position: relative;
  text-align: center;
}

.logo {
  max-width: 220px;
  margin-bottom: 20px;
  margin-top: -120px;
  filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.2));
}

.hero-text {
  color: white;
  font-size: 2.5rem;
  text-align: center;
  font-weight: 800;
  margin-bottom: 60px;
  line-height: 1.4;
  margin-top: 80px;
}

.start-button {
  background: linear-gradient(135deg, #6ad431 0%, #56c118 100%);
  color: white;
  font-weight: 700;
  font-size: 1.4rem;
  padding: 16px 60px;
  margin-bottom: 60px;
  border-radius: 40px;
  box-shadow: 0 10px 25px rgba(106, 212, 49, 0.3);
  letter-spacing: 1px;
  transition: all 0.3s ease;
  transform: scale(1);
}

.start-button:hover {
  transform: scale(1.05);
  box-shadow: 0 15px 30px rgba(106, 212, 49, 0.4);
}

/* Media queries for Responsiveness */
@media (max-width: 768px) {
  .brand-name {
    font-size: 3.5rem;
    margin-bottom: 80px;
  }
  .hero-text {
    font-size: 2.2rem;
    margin-top: 60px;
  }
  .logo {
    max-width: 180px;
    margin-top: -100px;
  }
}

@media (max-width: 480px) {
  .brand-name {
    font-size: 2.8rem;
    margin-bottom: 60px;
  }
  .hero-text {
    font-size: 1.8rem;
    margin-top: 50px;
    margin-bottom: 40px;
  }
  .logo {
    max-width: 160px;
    margin-top: -80px;
  }
  .start-button {
    padding: 14px 50px;
    font-size: 1.2rem;
  }
  .login-text, .login-link {
    font-size: 1rem;
  }
}
</style>