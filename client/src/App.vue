<script setup>
import { ref } from 'vue';

const leftDrawerOpen = ref(false);

const toggleLeftDrawer = () => {
  leftDrawerOpen.value = !leftDrawerOpen.value;
};

</script>

<template>
  <q-layout view="hHh lpR fFf">
    <q-header elevated class="bg-dark text-white" height-hint="98">
      <q-toolbar>
        <q-btn dense flat round icon="menu" @click="toggleLeftDrawer" />

        <q-toolbar-title>
          <q-avatar>
            <img src="./assets/FrameItLogo.png" />
          </q-avatar>
          Frame.It
        </q-toolbar-title>
      </q-toolbar>

      
    </q-header>

    <q-drawer v-model="leftDrawerOpen" side="left" bordered>
    <!-- Drawer Content -->
    <q-tabs align="left" vertical>
      <q-route-tab to="/" label="Home" />
      <q-route-tab to="/impressum" label="Impressum" />
    </q-tabs>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<style>
@font-face {
  font-family: 'Montserrat';
  src: url('/fonts/Montserrat/Montserrat-Regular.ttf') format('truetype');
}

@font-face {
  font-family: 'Lora';
  src: url('/fonts/Lora/Lora-Regular.ttf') format('truetype');
}

@font-face {
  font-family: 'LibreBodoni';
  src: url('/fonts/LibreBodoni/LibreBodoni-Regular.ttf') format('truetype');
}

* {
  font-family: 'Montserrat';
}
</style>
