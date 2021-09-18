# Dean Attali, July 2015
# https://github.com/daattali/advanced-shiny/tree/master/api-ajax

# listen for when javascript makes an api call
shiny::observeEvent(session$input[['api']], {
    # grab all the call parameters
    params <- session$input[['api']]

    # determine what R method to call
    method <- params[['_method']]
    method <- sprintf("api.%s", method)

    # save the request ID
    reqid  <- params[['_reqid']]

    # remove the meta params from the param list
    params[['_method']] <- NULL
    params[['_reqid']]  <- NULL

    # attempt to run the R function and return the response, along with request ID
    tryCatch({
        response <- do.call(method, as.list(list(params)))
        response <- as.list(response)
        response['_reqid'] <- reqid

        session$sendCustomMessage(type = "api.callback", response);
    },
    error = function(err) {
        # if an error occurs, call the error callback
        message("api error: ", err$message)
        response <- list(message = err$message, `_reqid`  = reqid)
        session$sendCustomMessage(type = "api.failureCallback", response);
    })
})
