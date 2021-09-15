## Internal function to combat-adjust for one marker
#'
#' @param marker column name of marker to normalize
#' @param slide_var column name of slide identifier
#' @param ndat multiplexed data to normalize. Data assumed to be a data.frame with cell-level data.
#' @param remove_zeroes boolean to remove zeroes from ComBat analysis (default=TRUE)
#' @param tol tolerance of ComBat algorithm (default=0.0001)
#'
#' @references Johnson, W. E., Li, C., & Rabinovic, A. (2007). Adjusting batch effects in microarray expression data using empirical Bayes methods. *Biostatistics*, 8(1), 118-127.
#'
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#'
#' @return ComBat adjusted values
run_combat = function(marker,
                      slide_var,
                      ndat,
                      remove_zeroes=TRUE,
                      tol = 0.0001){

    ## boolean for later
    zeroes_removed = FALSE
    if(remove_zeroes & nrow(ndat[ndat[,marker] <=0,]) > 0){
        ## remove zeroes if needed
        leftover = ndat[ndat[,marker] <=0,]
        ndat = ndat[(ndat[,marker] > 0),]
        zeroes_removed = TRUE
    }

    ### -------COMBAT EMPIRICAL VALUES-------

    ## get alpha (grand mean)
    ndat$alpha_c = mean(ndat[,marker])

    pre_gamma_ic = ndat %>%
        dplyr::group_by_at(slide_var) %>%
        dplyr::summarise(avg=mean(get(marker)), .groups = 'drop')
    ndat$pre_gamma_ic = pre_gamma_ic[match(ndat[,slide_var],unlist(pre_gamma_ic[,slide_var])),]$avg
    ndat$pre_gamma_ic = ndat$pre_gamma_ic

    ndat[,paste0("Adj_",marker)] = ndat[,marker] - ndat$alpha_c - ndat$pre_gamma_ic
    sigma_c = stats::var(ndat[,paste0("Adj_",marker)])
    ndat[,marker] = (ndat[,marker] - mean(ndat[,marker]))/sigma_c

    ## get gammas (slide means)
    gamma_ic = ndat %>%
        dplyr::group_by_at(slide_var) %>%
        dplyr::summarise(avg=mean(get(marker)), .groups = 'drop')

    ndat$gamma_ic = gamma_ic[match(ndat[,slide_var],unlist(gamma_ic[,slide_var])),]$avg
    ndat$gamma_ic = ndat$gamma_ic

    ## get deltas (slide variances)
    ndat$delta_ijc = ndat[,marker]

    delta_ijc = ndat %>%
        dplyr::group_by_at(slide_var) %>%
        dplyr::summarise(v=sum((get(marker) - gamma_ic)^2), .groups='drop')

    ndat$delta_ijc = (delta_ijc[match(ndat[,slide_var],unlist(delta_ijc[,slide_var])),]$v)

    ### -------COMBAT HYPERPARAMETERS-------
    ## slide level mean
    gamma_c = mean(ndat$gamma_ic)
    tau_c = stats::var(ndat$gamma_ic)

    ## slide level variances
    M_c = mean(ndat$delta_ijc)
    S_c = stats::var(ndat$delta_ijc)

    ## delta hyperparams
    omega_c = (M_c + 2*S_c)/S_c
    beta_c = (M_c^3 + M_c*S_c)/S_c

    ### -------CALLING COMBAT BATCH EFFECTS FUNCTIONS-------
    ndat$delta_ijc_inv = 1/ndat$delta_ijc

    ## option to output hyperparameters?
    # gamma_c; tau_c
    # M_c; S_c
    # omega_c; beta_c

    ### -------COMBAT BATCH EFFECT ADJUSTMENT-------

    ## run a single iteration
    ## run delta first
    delta_stars = update_delta(ndat, beta_c, omega_c,marker,slide_var)
    check_delta_conv = delta_conv(ndat, delta_stars,slide_var)
    ndat$delta_ijc = (delta_stars[match(ndat[,slide_var],unlist(delta_stars[,slide_var])),]$avg)
    ndat$delta_ijc_inv = 1/ndat$delta_ijc

    ## now update gamma
    gamma_stars = update_gamma(ndat, gamma_c, tau_c,marker,slide_var=slide_var)
    check_gamma_conv = gamma_conv(ndat, gamma_stars,slide_var=slide_var)
    ndat$gamma_ic = gamma_stars[match(ndat[,slide_var],unlist(gamma_stars[,slide_var])),]$avg

    total_mae = sum(check_gamma_conv,check_delta_conv)

    ## run until convergence
    while(total_mae > tol){
        ## run delta first
        delta_stars = update_delta(ndat, beta_c, omega_c,marker,slide_var)
        check_delta_conv = delta_conv(ndat, delta_stars,slide_var)
        ndat$delta_ijc = (delta_stars[match(ndat[,slide_var],unlist(delta_stars[,slide_var])),]$avg)
        ndat$delta_ijc_inv = 1/ndat$delta_ijc

        ## now update gamma
        gamma_stars = update_gamma(ndat, gamma_c, tau_c,marker,slide_var=slide_var)
        check_gamma_conv = gamma_conv(ndat, gamma_stars,slide_var=slide_var)
        ndat$gamma_ic = gamma_stars[match(ndat[,slide_var],unlist(gamma_stars[,slide_var])),]$avg

        total_mae = sum(check_gamma_conv,check_delta_conv)
    }

    ### -------COMBAT BATCH EFFECT RESULTS-------

    ## now adjust for the batch effects
    ndat$Y_ijc_star = (sigma_c/ndat$delta_ijc)*(ndat[,marker] - ndat$gamma_ic) + ndat$alpha_c

    ## add zeroes back in if needed
    if(zeroes_removed){
        ## add back in zeroes
        leftover$Y_ijc_star = 0
        leftover[,colnames(ndat)[!(colnames(ndat) %in% colnames(leftover))]] = NA
        ndat = rbind(ndat,leftover)
    }

    ndat$Y_ijc_star
}


## Update ComBat gamma (mean) parameters each iteration of the algorithm
#'
#' @param batch_chan,gamma_c,tau_c,channel,slide_var Internal objects created/used in `run_combat`
#'
#' @return Updated gamma values
update_gamma = function(batch_chan,
                        gamma_c,
                        tau_c,
                        channel,
                        slide_var){
    batch_chan$gamma_num = batch_chan[,channel]

    countr = batch_chan %>%
        dplyr::group_by_at(slide_var) %>%
        dplyr::count()

    gamma_num = batch_chan %>%
        dplyr::group_by_at(slide_var) %>%
        dplyr::summarise(avg = mean(gamma_num),.groups='drop')

    gamma_num$avg = (countr$n * tau_c * gamma_num$avg) + gamma_c * unique(batch_chan$delta_ijc)
    gamma_denom = countr$n * tau_c + unique(batch_chan$delta_ijc)

    gamma_ic_star = gamma_num
    gamma_ic_star$avg = gamma_ic_star$avg / gamma_denom

    return(gamma_ic_star)
}

## Update ComBat delta (variance) parameters each iteration of the algorithm
#'
#' @param batch_chan,beta_c,omega_c,channel,slide_var Internal objects created/used in `run_combat`
#'
#' @return Updated delta values
update_delta = function(batch_chan,
                        beta_c,
                        omega_c,
                        channel,
                        slide_var){
    batch_chan$delta_vals = batch_chan[,channel]

    delta_num = batch_chan %>%
        dplyr::group_by_at(slide_var) %>%
        dplyr::summarise(avg = sum((.data$delta_vals - .data$gamma_ic)^2),.groups='drop')

    delta_denom = batch_chan %>%
        dplyr::group_by_at(slide_var) %>%
        dplyr::count()

    delta_denom$n = delta_denom$n/2 + omega_c - 1
    delta_num$avg = 0.5*delta_num$avg + beta_c

    delta_ijc_star = delta_num
    delta_ijc_star$avg = delta_ijc_star$avg/delta_denom$n

    return(delta_ijc_star)
}

## Internal function to check convergence of gamma terms
#'
#' @param batch_chan,gamma_stars,slide_var Internal objects created/used in `run_combat`
#'
#' @return MAE between previous and updated gamma values
gamma_conv = function(batch_chan,
                      gamma_stars,
                      slide_var){
    gams = batch_chan[,c(slide_var,'gamma_ic')] %>%
        dplyr::distinct()
    return(mean(abs(gams[match(unlist(gamma_stars[,slide_var]),
                               gams[,slide_var]),]$gamma_ic - gamma_stars$avg))) ## MAE
}

## Internal function to check convergence of delta terms
#'
#' @param batch_chan,delta_stars,slide_var Internal objects created/used in `run_combat`
#'
#' @return MAE between previous and updated delta values
delta_conv = function(batch_chan,
                      delta_stars,
                      slide_var){
    dels = batch_chan[,c(slide_var,'delta_ijc')] %>%
        dplyr::distinct()
    return(mean(abs(dels[match(unlist(delta_stars[,slide_var]),
                               dels[,slide_var]),]$delta_ijc - delta_stars$avg))) ## MAE
}
