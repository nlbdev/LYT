# Requires `/common`  
# Requires `control`  
# Requires `player`  
# Requires `/view/render`  

# -------------------

# This module serves as a router to the rest of the application and contains url entrypoints and event listeners


#     bc  => pagebeforecreate
#     c   => pagecreate
#     i   => pageinit
#     bs  => pagebeforeshow
#     s   => pageshow
#     bh  => pagebeforehide
#     h   => pagehide
#     rm  => pageremove

# -------------------

LYT.var =
  next: null # store nextpage 
  searchTerm: null # store last search term

$(document).ready ->
  LYT.player.init() if not LYT.player.ready
  LYT.render.init()

$(document).bind "mobileinit", ->
  LYT.router = new $.mobile.Router([
    "#book-details([?].*)?":
      handler: "bookDetails"
      events: "s,bs" #
    "#book-play([?].*)?":
      handler: "bookPlayer"
      events: "s"
    "#book-index([?].*)?":
      handler: "bookIndex"
      events: "s"
    "#settings":
      handler: "settings"
      events: "s"
    "#support":
      handler: "support"
      events: "s"
    "#about":
      handler: "about"
      events: "s"
    "#search([?].*)?":
      handler: "search"
      events: "s"
    "#login":
      handler: "login"
      events: "s"
    "#profile":
      handler: "profile"
      events: "s"
    "#bookshelf":
      handler: "bookshelf"
      events: "s"
   ], LYT.control, { ajaxApp: false }) #defaultHandler: 'bookDetails'
   
  $(LYT.service).bind "logon:rejected", () ->
    LYT.var.next = window.location.hash #if window.location.hash is "" you came from root
    log.message 'her er' + LYT.var.next
    
    $.mobile.changePage "#login"
  
  $(LYT.service).bind "logoff", ->
    LYT.player.clear()
    
    $.mobile.changePage "#login"
  
  $("[data-role=page]").live "pageshow", (event, ui) ->
    _gaq.push [ "_trackPageview", event.target.id ]
  
  $(LYT.service).bind "error:rpc", () ->
    #todo: apologize on behalf of the server 
  
