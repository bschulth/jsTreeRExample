# jsTreeRExample

- Example of using AJAX for lazy loading https://github.com/stla/jsTreeR content.
   - This is a simple example that lazily loads a filesystem tree
   - The same principle could be used to lazily load:
      - AWS S3 Bucket folders
      - Remote SSH/Filesystem
      - Database content

# R Package Requirements

```r
# shiny
utils::install.packages("shiny")

# shinyjs
utils::install.packages("shinyjs")

# fs
utils::install.packages("fs")

# jsTreeR
#utils::install.packages("jsTreeR")
# Notes as of 2021-Sep-18, the github master version is required for a bug fix
remotes::install_github("stla/jsTreeR")
```

# Install this package
```r
remotes::install_github("bschulth/jsTreeRExample")
```

# Run the example:
```r
jsTreeRExample::ajax_example_01()
```

# Source:

- https://github.com/bschulth/jsTreeRExample/blob/main/R/ajax_example_01.R

# Credits:

- Note this leverages AJAX ideas from Dean Attali:
   - https://github.com/daattali/advanced-shiny/tree/master/api-ajax
