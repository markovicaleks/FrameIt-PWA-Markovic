<template>
  <div class="container d-flex flex-column align-items-center">
    <q-table
      title="Reise-Videos"
      :rows="store.videos ? [...store.videos] : []"
      :columns="columns"
      row-key="id"
      :rows-per-page-options="[10]"
    >
      <template v-slot:body-cell-gps="props">
        <q-td :props="props">
          {{ props.row.gps_latitude || 'N/A' }}, {{ props.row.gps_longitude || 'N/A' }}
        </q-td>
      </template>

      <!-- Kamera-Button in der Actions-Spalte -->
      <template v-slot:body-cell-actions="props">
        <q-td :props="props">
          <q-btn color="primary" label="Foto machen" @click="openCamera(props.row.id)" />
        </q-td>
      </template>
    </q-table>

    <!-- Kamera-Overlay -->
    <q-dialog v-model="cameraOpen">
      <q-card>
        <q-card-section>
          <video ref="video" autoplay></video>
          <canvas ref="canvas" style="display: none"></canvas>
        </q-card-section>
        <q-card-actions align="center">
          <q-btn label="Foto aufnehmen" color="green" @click="capturePhoto" />
          <q-btn label="Schließen" color="red" @click="closeCamera" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useVideoStore } from '../stores/videoStore.js';

const store = useVideoStore();
const cameraOpen = ref(false);
const video = ref(null);
const canvas = ref(null);
let stream = null;

const columns = [
  { name: 'title', label: 'Titel', field: 'title', align: 'left', sortable: true },
  { name: 'place', label: 'Ort', field: 'place', align: 'left' },
  { name: 'city', label: 'Stadt', field: 'city', align: 'left' },
  { name: 'country', label: 'Land', field: 'country', align: 'left' },
  { name: 'continent', label: 'Kontinent', field: 'continent', align: 'left' },
  { name: 'gps', label: 'GPS Koordinaten', align: 'left' },
  { name: 'persons', label: 'Personen', field: 'persons', align: 'left' },
  { name: 'timestamp', label: 'Datum & Zeit', field: 'timestamp', align: 'left' },
  { name: 'trip', label: 'Reise', field: 'trip', align: 'left' },
  { name: 'actions', label: 'Actions', field: 'actions', align: 'left' },
];

onMounted(() => {
  if (store.videos.length === 0) {
    store.fetchVideo();
  }
});

const openCamera = async () => {
  cameraOpen.value = true;
  try {
    stream = await navigator.mediaDevices.getUserMedia({ video: true });
    video.value.srcObject = stream;
  } catch (err) {
    console.error('Kamera konnte nicht gestartet werden:', err);
  }
};

const capturePhoto = () => {
  if (!video.value || !canvas.value) return;
  const ctx = canvas.value.getContext('2d');
  canvas.value.width = video.value.videoWidth;
  canvas.value.height = video.value.videoHeight;
  ctx.drawImage(video.value, 0, 0, canvas.value.width, canvas.value.height);
  const imageData = canvas.value.toDataURL('image/png');
  console.log('Foto aufgenommen:', imageData);
  closeCamera();
};

const closeCamera = () => {
  cameraOpen.value = false;
  if (stream) {
    stream.getTracks().forEach((track) => track.stop());
  }
};
</script>

<style scoped>
video {
  width: 100%;
  border-radius: 10px;
}
</style>
