#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#' @export
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ajax_example_01 <- function() {

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # Needs
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    #library(shiny)
    #library(shinyjs)
    #library(fs)
    library(jsTreeR) # This has to be called to force jsTreeR::zzz.R to load .onAttach() handlers

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # File Type Icons
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    file_types <- list(
        file = list(
            icon = "far fa-file"
        ),
        folder = list(
            icon = "fa fa-folder folder"
        )
    )


    app <- list(
        ui = shiny::tagList(
            shinyjs::useShinyjs(),
            shiny::tags$style(
                shiny::HTML(c(
                    ".red {color: red;}",
                    ".green {color: green;}",
                    ".jstree-proton {font-weight: normal;}",
                    ".jstree-anchor {font-size: small;}",
                    "pre {font-weight: bold; line-height: 1;}"
                ))
            ),
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Make JS-AJAX API available in client context
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            shiny::includeScript(system.file("www/ajax/api.js", package = "jsTreeRExample")),

            shiny::div(
                style = "position: absolute; left:0; top:0; bottom:0; right:0; background-color: #292828; color: #FFFFFF",
                jsTreeR::jstreeOutput(outputId = "jstree01")
            )
        ),

        server = function(input, output, session){
            #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Local base directories to show in tree via lazy ajax api
            #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            base_dirs <- list(
                home = fs::path_expand_r("~"),
                root = fs::path_expand_r("/")
            )

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Add ajax api function calls, functions should be prefixed with "api."
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            api.get_children <- function(params){
                node <- params$node

                if (node$id == "#") {
                    base_dir <- "/"
                    tryCatch({
                        node = list(
                            text     = "Filesystem",
                            a_attr   = list("style" = "font-weight:bold;"),
                            state    = list(opened = TRUE),
                            children = unname(lapply(names(base_dirs), function(base_dir_name) {
                                base_dir <- base_dirs[[base_dir_name]]
                                list(
                                    text     = base_dir_name,
                                    a_attr   = list("style" = "font-weight:bold;"),
                                    state    = list(opened = TRUE),
                                    data     = list(absolute_path = base_dir),
                                    children = get_local_filesystem_children(parent_node = node, path = base_dir, base_dir = base_dir)
                                )
                            }))
                        )
                    }, error = function(e){
                        message(e$message)
                    })

                    return(list(node = node))
                } else {
                    base_dir <- node$data$base_dir
                    return(list(
                        node = get_local_filesystem_children(parent_node = node, path = node$data$absolute_path, base_dir = base_dir)
                    ))
                }
            }

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Make R-AJAX API available in server context
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            source(system.file("www/ajax/api.R", package = "jsTreeRExample"), local = environment(api.get_children))

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Support functions
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            get_local_filesystem_children = function(parent_node, path, base_dir) {
                parent_tree <- list()

                message("loading filesystem children for: ", path)

                child_paths <- fs::dir_info(path)
                child_paths <- child_paths[order(child_paths$type, child_paths$path),]
                child_paths$tree_id <- NA_integer_

                child_dirs  <- child_paths[child_paths$type == "directory",]
                if (nrow(child_dirs) > 0){
                    for (i_cd in 1:nrow(child_dirs)) {
                        rr <- child_dirs[i_cd, ]
                        r_name = basename(rr$path[[1]])

                        parent_tree[[length(parent_tree)+1]] <- list(
                            text = r_name,
                            state = list(
                                opened   = FALSE,
                                disabled = FALSE,
                                selected = FALSE
                            ),
                            a_attr = list(
                                "style" = "font-weight:bold;"
                            ),
                            children = TRUE,
                            data = list(
                                base_dir        = base_dir,
                                absolute_path = rr$path[[1]],
                                size          = rr$size[[1]],
                                perms         = rr$permissions[[1]],
                                modified      = rr$modification_time[[1]]
                            )
                        )
                    }
                }

                child_files <- child_paths[child_paths$type == "file",]
                if (nrow(child_files) > 0){
                    for (i_cf in 1:nrow(child_files)) {
                        rr <- child_files[i_cf, ]
                        r_name = basename(rr$path[[1]])
                        ext <- tolower(tools::file_ext(r_name))

                        color <- "white"
                        if (rr$size > 500000000) {
                            color = "red"
                        } else if (rr$size > 25000000) {
                            color = "yellow"
                        }

                        parent_tree[[length(parent_tree)+1]] <- list(
                            text = r_name,
                            type = "file",
                            a_attr = list(
                                "style" = sprintf("color:%s;", color)
                            ),
                            data = list(
                                base_dir      = base_dir,
                                absolute_path = rr$path[[1]],
                                size          = rr$size[[1]],
                                perms         = rr$permissions[[1]],
                                modified      = rr$modification_time[[1]],
                                parent        = parent_node
                            )
                        )
                    }
                }

                return(parent_tree)
            }


            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Add the tree, not we need to delay adding it so that the Shiny handlers load
            #   first
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

            #shinyjs::delay(ms=200, {

                ajax_hook <- htmlwidgets::JS("
                    function (obj, cb) {
                        var params = {};
                        params['_method']   = 'get_children'; //Reference to R: api.get_children()
                        params['node']      = obj;
                        this_data           = this;
                        params['_callback'] = function(response) {
                            cb.call(this_data, response.node);
                        }
                        api.call(params);
                    }
                ")

                output[["jstree01"]] <- jsTreeR::renderJstree({
                    jsTreeR::jstree(
                        nodes       = ajax_hook,
                        dragAndDrop = FALSE,
                        sort        = TRUE,
                        checkboxes  = FALSE,
                        multiple    = FALSE,
                        types       = file_types,
                        theme       = "proton"
                    )
                })
            #})

        }
    )

    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # Launch app as a 'gadget' in RStudio
    #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    shiny::runGadget(shiny::shinyApp(app$ui, app$server),viewer = shiny::paneViewer(minHeight = "maximize"))
}
