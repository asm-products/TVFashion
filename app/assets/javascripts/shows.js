var ready;
ready = function() {

  $('#search_form').on('submit', function(e) {
    e.preventDefault();
    
    var form = $(this);
    console.log(form)
    $.ajax({
      type: 'GET',
      url: '/show_searches/new',
      data: form.serialize(),
      dataType: 'JSON',
      success: function(response) {
        $('#search_form').hide();
        $.each(response, function(i, data) {
          $('#found_shows').append(
            $('<li>').append(
              $('<a>').attr('href', '#').attr('id', 'found_show').attr('data-show-id', data.id).append(
                $('<p>').attr('class', 'showName').append(data.SeriesName).append(
                  $('<span>').attr('class', 'showDate').append(' - ('+data.FirstAired+')') 
                )))
              );  
        }); 
        $('#found_shows').after($('<a>').attr('href', 'new').append('Search Again'));
        $('#found_shows').on('click','#found_show', function(e) {
          e.preventDefault();
          var show_link = $(this);
          console.log(show_link.data("showId"))
          $.ajax({
            type: 'POST',
            url: '/shows',
            data: { show_id: show_link.data("showId") },
            dataType: 'JSON',
            success: function(response) {
            window.location.href = response.id;
      },
      error: function(response) {
        console.log('ERROR');
      }
    })
  });
      },
      error: function(response) {
        console.log('ERROR');
      }
    })
  });
};

$(document).ready(ready);
$(document).on('page:load', ready);