var clip = new ZeroClipboard( document.getElementById("yank"), {
  moviePath: "ZeroClipboard.swf"
} );

clip.on( 'load', function(client) {} );

clip.on('complete', function(client, args) {
  alert("Copied text to clipboard: " + args.text );
} );


