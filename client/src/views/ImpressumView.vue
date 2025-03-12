<template>
  <div class="impressum-wrapper">
    <div class="header">
      <h1>Impressum</h1>
    </div>
    <div class="impressum-content">
      <h5>Frame.It</h5>
      <h5>Projekt von Aleksandar Markovic</h5>
    </div>
  </div>
</template>

<style scoped>
.impressum-wrapper {
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

.impressum-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  max-width: 800px;
  margin: 0 auto;
  background-color: #2d2d2d;
  border-radius: 12px;
  padding: 2rem;
}

.impressum-content h5 {
  color: white;
  margin: 0.5rem 0;
  font-size: 1.2rem;
}

@media (max-width: 600px) {
  .header h1 {
    font-size: 1.8rem;
  }
  
  .impressum-content {
    padding: 1.5rem;
  }
  
  .impressum-content h5 {
    font-size: 1.1rem;
  }
}
</style>