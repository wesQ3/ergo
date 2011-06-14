function redirect() {
   if (location.hash.match(/status\/(\d+)/)) {
      var stat = location.hash.match(/status\/(\d+)/);
      document.write(stat[1]);
      location = '/status/'+stat[1];
   } else {
   }
}

redirect();
