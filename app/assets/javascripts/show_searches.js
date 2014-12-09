$(document).ready(function() {
  $('#search_form').on('submit', function(e) {
    e.preventDefault();
    
    var form = $(this);
    
    $.ajax({
      type: 'POST',
      url: '/show_searches',
      data: form.serialize(),
      dataType: 'JSON',
      success: function(response) {
        $.each(response, function(i, data) {
          if (data.banner !== undefined){
          $('#found_shows').append(
            $('<li>').append(
              $('<a>').attr('href', 'show/create').append(
                $('<img>').attr('src','http://thetvdb.com/banners/'+data.banner).add(
                $('<p>').attr('class', 'tab').append(data.SeriesName).add(
                $('<p>').attr('class', 'tab2').append(data.FirstAired) 
                )))
              )
          );}  
        });     
        console.log(response);
      },
      error: function(response) {
        console.log('ERROR');
      }
    })
  });
});



