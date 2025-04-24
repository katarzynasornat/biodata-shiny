navigator.geolocation.getCurrentPosition(
  function(position) {
    Shiny.setInputValue('user_location', {
      lat: position.coords.latitude,
      lon: position.coords.longitude,
      found: true
    });
  },
  function(error) {
    Shiny.setInputValue('user_location', {
      found: false
    });
  }
);