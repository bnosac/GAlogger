#' @importFrom curl curl_escape curl_fetch_memory
#' @importFrom uuid UUIDgenerate
NULL


galog <- new.env()

.onLoad <- function(libname, pkgname) {
  galog$tracking_id <- Sys.getenv(x = "GALOG_UA_TRACKINGID", unset = NA)
  galog$client_id <- Sys.getenv(x = "GALOG_UA_CLIENTID", unset = NA)
  if(is.na(galog$client_id)){
    galog$client_id <- uuid::UUIDgenerate()  
  }
  galog$user_id <- Sys.getenv(x = "GALOG_UA_USERID", unset = NA)
  if(is.na(galog$user_id)){
    ga_set_user_id()
  }
  galog$consent <- Sys.getenv(x = "GALOG_CONSENT", unset = NA)
  galog$hostname <- Sys.getenv(x = "GALOG_HOSTNAME", unset = NA)
  galog$consent <- ifelse(galog$consent %in% "yes", TRUE, FALSE)
  ga_set_url()
  ga_set_approval_message()
  if(is.na(galog$user_id)){
    ## Setting hostname to 'GAlogger'
    ga_set_hostname()
  }

}

#' @title Provide the Google Analytics tracking ID where all user interactions will be logged to
#' @description The Google Analytics tracking ID looks something like UA-XXXXX-Y. For example UA-25938715-4.
#' Get your own tracking ID at the Google Analytics website.
#' All collected user interactions will be logged with that tracking ID.
#' @param x a character string with the Google Analytics tracking ID
#' @return invisibly a list all general settings used to send data to Google Analytics
#' @export
#' @examples
#' ga_set_tracking_id("UA-25938715-4")
ga_set_tracking_id <- function(x = "UA-25938715-4"){
  galog$tracking_id <- x
  ga_set_url()
  invisible(as.list(galog))
}

#' @title Provide the identifier which will be used to identify a visitor/user
#' @description Set the identifier of a visitor as it is known by you. 
#' The user_id identifier is the identifier of the visitor/user as it is know by you.
#' Defaults to a randomly generated identifier.\cr
#' 
#' You can also set the client_id identifier which anonymously identifies a particular user or device. 
#' For R users this client_id identifies the same user across different R sessions. 
#' The value of this field should be a random UUID (version 4) as described in \url{http://www.ietf.org/rfc/rfc4122.txt}\cr
#' By default for every new R session, a new client_id is generated.
#' @param user_id a character string with the visitor/user known to you. Defaults to a randomly generated UUID.
#' @param client_id a character string in UUID format which anonymously and uniquely identifies a particular R user or device across different R sessions.
#' Defaults to a randomly generated UUID.
#' @return invisibly a list all general settings used to send data to Google Analytics
#' @export
#' @examples
#' ga_set_user_id()
#' ga_set_user_id("root")
#' ga_set_user_id("team-datascientists")
#' ga_set_user_id("shiny-server")
#'
#' x <- sprintf("%s-%s", Sys.getpid(), tolower(Sys.getenv("USERNAME", unset = "default")))
#' x
#' ga_set_user_id(x)
#' ga_set_user_id(x, client_id = "a5d1eeb6-0459-11e8-8912-134976ff196e")
ga_set_user_id <- function(user_id = uuid::UUIDgenerate(), client_id = uuid::UUIDgenerate()){
  userid <- curl::curl_escape(user_id)
  galog$user_id <- userid
  if(!missing(client_id)){
    clientid <- curl::curl_escape(client_id)
    ga_set_client_id(clientid)
  }
  ga_set_url()
  invisible(as.list(galog))
}


ga_set_client_id <- function(x = uuid::UUIDgenerate()){
  userid <- curl::curl_escape(x)
  galog$client_id <- userid
  ga_set_url()
  invisible(as.list(galog))
}

ga_set_url <- function(){
  #v=1              // Version.
  #&tid=UA-XXXXX-Y  // Tracking ID / Property ID.
  #&cid=555         // This anonymously identifies a particular user, device, or browser instance
  #&uid=555         // Known identifier for a user provided by the site owner/tracking library user
  #&ds=GAlogger        // Data source: set to GAlogger

  # https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide
  # https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters

  galog$url <- sprintf("http://www.google-analytics.com/collect?v=1&tid=%s&cid=%s&uid=%s&ds=GAlogger",
                       galog$tracking_id,
                       galog$client_id,
                       galog$user_id)
  invisible(as.list(galog))
}

ga_set_hostname <- function(x='GAlogger'){
  stopifnot(is.character(x) & length(x) == 1 & nchar(x) > 0)
  galog$hostname <- x
  invisible(as.list(galog))
}

ga_set_approval_message <- function(x){
  if(missing(x)){
    x <- sprintf("Hello %s
This is just a message to inform you that we are collecting information how you use this application\nWe will send the following information to Google Analytics:
- Which parts of our application you are using
- When errors are occurring
- Your information will be tracked anonymously as user %s
- This information is collected in order to provide us better insights on how people use this application\n",
                 Sys.getenv("USERNAME"), galog$user_id)
  }
  galog$message <- x
  invisible(as.list(galog))
}

#' @title Request for approval of the user to send information to Google Analytics
#' @description Request for approval of the user to send information to Google Analytics.
#' The approval is requested by setting yes/no in the prompt if consent is set to FALSE and the user is working in interactive mode.\cr
#' If consent is set to TRUE, the developer is responsible for complying to legislation in your area like the 
#' General Data Protection Regulation (GDPR) in Europa.
#' @param message a character string with a message to show to the user before approval is requested. If not given will show a default message.
#' @param consent logical indicating to give approval. Defaults to FALSE indicating that no approval is given.
#' @return invisibly a list all general settings used to send data to Google Analytics
#' @export
#' @examples
#' ## Request user input
#' ga_set_approval(consent = FALSE)
#' ga_set_approval(consent = FALSE,
#'                 message = "Please approve that we send usage information to Google Analytics")
#'
#' ## Developer sets consent directly assuming that he received approval in another way
#' ga_set_approval(consent = TRUE)
ga_set_approval <- function(message, consent = FALSE){
  ## Print out the message to ask for approval of sending data
  if(missing(message)){
    cat(galog$message, sep = "\n")
  }else{
    cat(message, sep = "\n")
  }
  ## If consent is set to TRUE, approval is set by the developer who is responsible
  ## If consent is set to FALSE and in interactive mode, request for approval
  if(consent == TRUE){
    consent <- ifelse(consent, "yes", "no")
  }else{
    if(interactive()) {
      consent <- readline(prompt="Is that ok for you (yes/no): ")
    }else{
      consent <- ifelse(consent, "yes", "no")
    }
  }
  ## Print out a note and set consent to TRUE/FALSE
  if(consent == "yes"){
    galog$consent <- TRUE
    cat("Thank you for your consent to send usage data to Google Analytics")
  }else{
    galog$consent <- FALSE
    cat("No consent given")
  }
  invisible(as.list(galog))
}




#' @title Send events to Google Analytics
#' @description Send events to Google Analytics.
#' If an event happens in your script, use this function to send the event to Google Analytics.
#' An event has a category, an action and optionally a label and a value can be set for the event. \cr
#' Possible use cases of this are sending when a user loads your package, sending when a user does some action on your shiny application,
#' storing when a user uses your R webservice, keeping information on the status of a long-running process, sending and error message ...\cr
#'
#' Events can be viewed in the Google Analytics > Behaviour > Events tab or in the Real-Time part of Google Analytics.
#' @param event_category a character string of length 1 with the category of the event
#' @param event_action a character string of length 1 with the action of the event
#' @param event_label a character string of length 1 with the label of the event. This is optional.
#' @param event_value a integer of length 1 with the value of the event. This is optional.
#' @return invisibly the result of a call to \code{\link[curl]{curl_fetch_memory}} which sends the data to Google Analytics
#' or an object of try-error if the internet is not working
#' @export
#' @examples
#' ga_set_tracking_id("UA-25938715-4")
#' ga_set_approval(consent = TRUE)
#'
#' ga_collect_event(event_category = "Start", event_action = "shiny app launched")
#' ga_collect_event(event_category = "Simulation",
#'                  event_label = "Launching Bayesian multi-level model",
#'                  event_action = "How many simulations", event_value = 10)
#' ga_collect_event(event_category = "Error",
#'                  event_label = "convergence failed", event_action = "Oh no")
#' ga_collect_event(event_category = "Error",
#'                  event_label = "Bad input", event_action = "send the firesquad", event_value=911)
ga_collect_event <- function(event_category="Start", event_action="default", event_label, event_value){
  # &ec=video        // Event Category. Required.
  # &ea=play         // Event Action. Required.
  # &el=holiday      // Event label.
  # &ev=300          // Event value.
  event_category <- curl::curl_escape(event_category)
  event_action <- curl::curl_escape(event_action)

  url <- sprintf("%s&t=event&ec=%s&ea=%s", galog$url, event_category, event_action)
  if(!missing(event_label)){
    stopifnot(is.character(event_label))
    event_label <- curl::curl_escape(as.character(event_label))
    url <- sprintf("%s&el=%s", url, event_label)
  }
  if(!missing(event_value)){
    stopifnot(is.numeric(event_value))
    event_value <- curl::curl_escape(as.character(event_value))
    url <- sprintf("%s&ev=%s", url, event_value)
  }
  req <- send(url)
  invisible(req)
}

#' @title Send pageviews to Google Analytics
#' @description Send pageviews to Google Analytics.
#' If someone visits a page, use this function to send the page and title of the page which is visited so that you can
#' easily see how users are using your application. \cr
#'
#' Pageviews can be viewed in the Google Analytics > Behaviour tab or in the Real-Time part of Google Analytics.
#' @param page a character string with the page which was visited
#' @param title a character string with the title of the page which was visited
#' @param hostname a character string with the hostname. Defaults to the environment variable GALOG_HOSTNAME and if not set uses 'GAlogger'.
#' @return invisibly the result of a call to \code{\link[curl]{curl_fetch_memory}} which sends the data to Google Analytics
#' or an object of try-error if the internet is not working
#' @export
#' @examples
#' ga_set_tracking_id("UA-25938715-4")
#' ga_set_approval(consent = TRUE)
#'
#' ga_collect_pageview(page = "/home")
#' ga_collect_pageview(page = "/simulation", title = "Mixture process")
#' ga_collect_pageview(page = "/simulation/bayesian")
#' ga_collect_pageview(page = "/textmining-exploratory")
#' ga_collect_pageview(page = "/my/killer/app")
#'
#' x <- ga_collect_pageview(page = "/home", title = "Homepage", hostname = "www.xyz.com")
#' x$status_code
ga_collect_pageview <- function(page="/home", title=page, hostname=galog$hostname){
  #&dh=mydemo.com   // Document hostname.
  #&dp=/home        // Page.
  #&dt=homepage     // Title.
  hostname <- curl::curl_escape(as.character(hostname))
  page <- curl::curl_escape(as.character(page))
  url <- sprintf("%s&t=pageview&dh=%s&dp=%s", galog$url, hostname, page)
  if(!missing(title)){
    title <- curl::curl_escape(as.character(title))
    url <- sprintf("%s&dt=%s", url, title)
  }
  req <- send(url)
  invisible(req)
}

send <- function(url){
  if(is.na(galog$tracking_id)){
    stop("You forgot to set the tracking_id which looks like UA-XXXXX-Y, see ?ga_set_tracking_id")
  }
  if(galog$consent){
    ## Send the data, put it in a try block to avoid the R program stops
    result <- try(curl_fetch_memory(url), silent = TRUE)
    return(result)
  }else{
    invisible()
  }
}


