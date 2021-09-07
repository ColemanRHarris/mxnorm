.trim_dataset <- function(data,
                          slide_id,
                          image_id,
                          marker_cols,
                          metadata_cols = NULL){
    if(!is.null(metadata_cols)){
        return(data[,c(slide_id,image_id,marker_cols,metadata_cols)])
    }

    data[,c(slide_id,image_id,marker_cols)]
}
