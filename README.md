# GAlogger - Log R Events and R Usage to Google Analytics

Easily track how R users use your application by sending pageviews or events to Google Analytics. Developed with the following use cases in mind

**Track usage of your application**

- If someone visits a page in your web application (e.g. Shiny) or web service (e.g. RApache, Plumber), use this R package to send the page and title of the page which is visited so that you can easily see how visitors are using your application
- Do you want to know which user inputs are set in your Shiny app, you can now collect these events easily with this R package

**Track usage of your scripts / package usage / functions**

- Keep track on how your internal useRs are using your package (e.g. when a user loads your package or uses a specific function or webservice)
- Do you want to keep track on the status of a long-running process or keep track of an error message if something failed.

![](https://github.com/bnosac/GAlogger/raw/master/README-screenshot-1.png)

## Set-up

Get your UA tracking ID from Google Analytics (it looks like UA-XXXXX-Y) and indicate that you approve that data will be send to Google Analytics.

```
library(GAlogger)
ga_set_tracking_id("UA-25938715-4")
ga_set_approval(consent = TRUE)
```

## Usage

### Visits

**Someone is visiting your app, great, log it is follows.**

```
ga_collect_pageview(page = "/home")
ga_collect_pageview(page = "/simulation", title = "Mixture process")
ga_collect_pageview(page = "/simulation/bayesian")
ga_collect_pageview(page = "/textmining-exploratory")
ga_collect_pageview(page = "/my/killer/app")
ga_collect_pageview(page = "/home", title = "Homepage", hostname = "www.xyz.com")
```

### Events

**An event is happening in your app or R code, great, log it as follows.**

```
ga_collect_event(event_category = "Start", event_action = "shiny app launched")
ga_collect_event(event_category = "Error", event_label = "convergence failed", event_action = "Oh no")
ga_collect_event(event_category = "Error", event_label = "Bad input", 
                 event_action = "send the firesquad", event_value = 911)
ga_collect_event(event_category = "Simulation", event_label = "Launching Bayesian multi-level model",
                 event_action = "How many simulations", event_value = 10)                 
```

![](https://github.com/bnosac/GAlogger/raw/master/README-screenshot-2.png)


## Installation

Install the development version of the package with `remotes::install_github("bnosac/GAlogger")` Or install the ready-made R package from www.datatailor.be as follows.

```
install.packages("uuid")
install.packages("curl")
install.packages("GAlogger", repos = "http://www.datatailor.be/rcube", type = "source")
```


## Advanced usage

At package startup, the package looks to 5 environment variables. Set these in your startup files .Rprofile/.Renviron or .bashrc if you want to avoid having to specify these in your R code itself.

- `GALOG_UA_TRACKINGID`: the Google Analytics tracking ID
- `GALOG_UA_USERID`: the identifier of the user of your application as known by you. E.g. someones name.
- `GALOG_UA_CLIENTID`: an identifier in UUID format which anonymously and uniquely identifies a particular R user or device across different R sessions.
- `GALOG_HOSTNAME`: the hostname which is used in `ga_collect_pageview` of not given in the argument `hostname`
- `GALOG_CONSENT`: Set to the value of `yes` if you automatically want to give consent 


```
Sys.setenv('GALOG_UA_TRACKINGID' = "UA-25938715-4")
Sys.setenv('GALOG_UA_USERID' = "datascientist-workstation-xyz")
Sys.setenv('GALOG_UA_USERID' = "a5d1eeb6-0459-11e8-8912-134976ff196e")
Sys.setenv('GALOG_HOSTNAME' = "www.mywebapplication.org")
Sys.setenv('GALOG_CONSENT' = "yes")

library(GAlogger)
ga_collect_pageview(page = "/home")
ga_collect_event(event_category = "Waw", event_action = "I got visitors")
```

This package by itself does not send private information to Google Analytics, the R developer itself is responsible for making sure not to send any information which he/she does not want to see appearing in Google Analytics or he/she is not entitled to store elsewhere. If you do not trust this statement, just look at the R source code at https://github.com/bnosac/GAlogger/blob/master/R/pkg.R, it is pretty basic and is released under the Mozilla Public License 2.0 so you can see what id does. 


## Support in R application development

Need support in R application development?
Contact BNOSAC: http://www.bnosac.be

