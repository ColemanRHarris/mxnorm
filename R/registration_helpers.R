#' @title Internal function to register one marker
#'
#' @param marker column name of marker to normalize
#' @param slide_var column name of slide identifier
#' @param ndat multiplexed data to normalize. Data assumed to be a data.frame with cell-level data.
#' @param len the number of equally spaced points at which the density is to be estimated. See `stats::density()` argument `n` for more details (default=512)
#' @param weighted boolean to determine if weighted mean to be used via `weighted.mean.fd()` (default=TRUE)
#' @param offset offset from zero when calculating weights (default=0.0001)
#' @param fdobj_norder 	an integer specifying the order of b-splines for the histogram approximation. See `fda::create.bspline.basis()` argument `norder` for more details. (default=4)
#' @param fdobj_nbasis an integer variable specifying the number of basis functions for the histogram approximation. See `fda::create.bspline.basis()` argument `nbasis` for more details. (default=21)
#' @param w_norder an integer specifying the order of b-splines for the linear transformation. See `fda::create.bspline.basis()` argument `norder` for more details. (default=2)
#' @param w_nbasis an integer variable specifying the number of basis functions for the linear transformation. See `fda::create.bspline.basis()` argument `nbasis` for more details.(default=2)
#'
#' @return Registration adjusted values
#' @noRd
run_registration = function(marker,
                            slide_var,
                            ndat,
                            len=512,
                            weighted=TRUE,
                            offset=0.0001,
                            fdobj_norder=4,
                            fdobj_nbasis=21,
                            w_norder=2,
                            w_nbasis=2){
    ## scale data if needed
    if(sum(ndat[,marker]<0) > 0){
        ndat[ndat[,marker]<0,marker] = 0
    }

    ## ---- data setup
    x = split(ndat,factor(ndat[,slide_var])) ## split data by slide
    rang = range(ndat[which(ndat[,marker]!=0),marker]) ## get range of values != 0
    if(rang[1] < 0){rang[1] = 0}
    argvals = seq(rang[1],rang[2],len=len) ## get evenly spaced values for computation later

    ## ---- density of marker
    densY = sapply(1:length(x), function(i){ ## calculate density for each nonzero value across slides
        stats::density(x[[i]][,marker][which(x[[i]][,marker]!=0)],
                       from=rang[1],
                       to=rang[2],
                       n=len,
                       na.rm=TRUE)$y
    })

    ## ---- setup basis functions
    fdobj_basis = fda::create.bspline.basis(rangeval = rang, norder = fdobj_norder,nbasis=fdobj_nbasis) ## create bspline basis with cubic splines (approx hist)
    wbasis = fda::create.bspline.basis(rangeval = rang, norder = w_norder,nbasis=w_norder) ## create bspline basis with linear (transform data)
    Wfd0   <- fda::fd(matrix(0,wbasis$nbasis,1),wbasis) ## setup `fda` object
    WfdPar <- fda::fdPar(Wfd0, Lfdobj = fda::int2Lfd(0),lambda = 0) ## setup roughness for `fda` object

    ## ---- initial registration (warp functions)
    fdobj   <- fda::smooth.basis(argvals, densY, fdobj_basis, fdnames = c("x", "samples", "density"))$fd ## estimates the densities using bsplines

    ## ---- reverse registration (inverse warp functions)
    if(weighted==TRUE){
        x1 = split(ndat[,marker],factor(ndat[,slide_var])) ## split data by slide
        w = sapply(x1, function(y) sum(y>offset))
        y0s = weighted.mean.fd(fdobj, w=w)
    }else{
        y0s = fda::mean.fd(fdobj) ## get mean curve from registration
    }

    y0s$coefs = do.call(cbind, rep(list(y0s$coefs), ncol(fdobj$coefs)))
    regDens = fda::register.fd(y0fd = fdobj, yfd=y0s,WfdParobj = WfdPar, dbglev = 0,crit = 1) ## register to get actual warping functions back to real data

    normed_marker = paste0(marker,"_adjusted")
    ## ---- register raw data
    xp = lapply(1:length(x), ## register each slide using inverse warp functions
                function(ind){
                    x[[ind]] = data.frame(x[[ind]])
                    x[[ind]][,normed_marker] = 0;
                    x[[ind]][which(x[[ind]][,marker]>0),normed_marker] = fda::eval.fd(x[[ind]][which(x[[ind]][,marker]>0), marker], regDens$warpfd[ind]);
                    x[[ind]]})

    ndat = data.frame(data.table::rbindlist(xp))

    return(ndat[,normed_marker]) ## combine data into initial form with registered values included
}

#' @title Calculate weighted mean of fda object
#'
#' @param x,w,... Internal objects created/used in `run_registration`
#'
#' @return Weighted mean of fda object
#' @noRd
weighted.mean.fd = function (x, w, ...)
{
    if (!inherits(x, "fd"))
        stop("'x' is not of class 'fd'")
    coef <- x$coefs
    coefd <- dim(coef)
    ndim <- length(coefd)
    basisobj <- x$basis
    nbasis <- basisobj$nbasis
    dropind <- basisobj$dropind
    ndropind <- length(dropind)
    if (ndim == 2) {
        coefmean <- matrix(apply(coef, 1, stats::weighted.mean, w=w), nbasis - ndropind,
                           1)
        coefnames <- list(dimnames(coef)[[1]], "Mean")
    }
    else {
        nvar <- coefd[3]
        coefmean <- array(0, c(coefd[1], 1, nvar))
        for (j in 1:nvar) coefmean[, 1, j] <- apply(coef[, ,
                                                         j], 1, stats::weighted.mean, w=w)
        coefnames <- list(dimnames(coef)[[1]], "Mean", dimnames(coef)[[3]])
    }
    fdnames <- x$fdnames
    fdnames[[2]] <- "mean"
    fdnames[[3]] <- paste("mean", fdnames[[3]])
    meanfd <- fda::fd(coefmean, basisobj, fdnames)
    meanfd
}
