library(tidyverse)
library(googledrive)

fls <- drive_ls('PM25_USGrid') %>%
  filter(grepl('PredictionStep2', name, fixed = TRUE))

d <- fls %>%
  mutate(date = map_chr(name, ~ substr(., 38, 45)),
         date = as.Date(date, '%Y%m%d')) %>%
  arrange(date) %>%
  select(-drive_resource)

dir.create('pm_fst')

dl_and_convert_to_fst <- function(row_index = 1) {
  d_row <- slice(d, row_index)
  date <- pull(d_row, date)
  file_name <- pull(d_row, name)
  id <- pull(d_row, id)
  if (file.exists(paste0('./pm_fst/', date, '.fst'))) return(NULL)
  message(date)
  on.exit(unlink(file_name))
  drive_download(as_id(id), verbose = FALSE, overwrite = FALSE)
  pm_data <- readRDS(file_name) %>% as.vector() %>% round(digits = 2)
  fst::write_fst(tibble(pm = pm_data), paste0('./pm_fst/', date, '.fst'), compress = 100)
}

## keep running this until all files are downloaded
walk(1:nrow(d), purrr::safely(dl_and_convert_to_fst))

## while (TRUE) {CB::mappp(1:nrow(d), purrr::safely(dl_and_convert_to_fst), parallel = TRUE)}


## check to see if all dates are available
list.files('pm_fst', pattern = '.fst') %>%
  tools::file_path_sans_ext() %>%
  length()

## expecting 6,210 dates between 2000 and 2016
seq(as.Date('2000-01-01'), as.Date('2016-12-31'), by = 1) %>%
  length()
