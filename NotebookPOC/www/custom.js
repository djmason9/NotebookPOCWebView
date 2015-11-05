$(function(){//on load
 
  $('body').keypress(function() {
      window.location = "etext2edit://etext2webEdit";
  });
  
  $('body').focus(function() {
     window.location = "etext2edit://etext2webFocus";
  });
  
});

