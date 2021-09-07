library(dplyr)
set.seed(42)

n_slide = 4
n_image = 3
n_cells = 250


slide_id = paste0("slide",1:n_slide) %>%
    rep(each=n_image * n_cells)
image_id = paste0("image",1:n_image) %>%
    rep(each=n_cells) %>%
    rep(n_slide)
marker1_vals = runif(n_slide * n_image * n_cells, min = 0, max = 100) %>%
    round()
marker2_vals = runif(n_slide * n_image * n_cells, min = 0, max = 1000) %>%
    round()
marker3_vals = runif(n_slide * n_image * n_cells, min = 0, max = 10000) %>%
    round()

mx_sample = data.frame(cbind(slide_id,
                 image_id,
                 marker1_vals,
                 marker2_vals,
                 marker3_vals))
