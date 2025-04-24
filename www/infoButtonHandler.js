document.addEventListener('DOMContentLoaded', function() {
    var infoBtn = document.getElementById('info_btn');
    if (infoBtn) {
      infoBtn.addEventListener('click', function() {
        Shiny.setInputValue('info_btn', Math.random());
      });
    }
  });