String.format = function() {
   var s = arguments[0];
   for (var i = 0; i < arguments.length - 1; i++) {       
      var reg = new RegExp("\\{" + i + "\\}", "gm");             
      s = s.replace(reg, arguments[i + 1]);
   }

   return s;
}

function redirect() {
   if (location.hash.match(/status\/(\d+)/)) {
      var stat = location.hash.match(/status\/(\d+)/);
      document.write(stat[1]);
      location = '/status/'+stat[1];
   } else {
   }
}

function friendlyDates() {
   $('.raw.date').replaceWith(
      function() { 
         return new Date( $( this ).text() ).toLocaleString(); })
      .removeClass('raw');
}

function showConversation(id) {
   var replyID = id || $('#main-tweet > .reply-to').text();
   console.log('fetching', replyID);
   if (replyID) {
      $.ajax({ 
         url: '/status/' + replyID + '.json',
         success: function( data, status, xhr ) {
            var newTweet = 
               String.format(rawTweet, data.text, data.user.screen_name, data.created_at);
            $('body').prepend(newTweet);
            friendlyDates();
            if (data.in_reply_to_status_id) {
               showConversation(data.in_reply_to_status_id);
            }
         }
      });
   }
}
var rawTweet = '\
   <div class="tweet">\
      <span class="tweet-text">{0}</span>\
      <div class="by-line">\
         ~<span class="user-name">{1}</span> @ <span class="raw date">{2}</span>\
      </div>\
   </div>';

$( function(){
   friendlyDates();
   showConversation();
});
