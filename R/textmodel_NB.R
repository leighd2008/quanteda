#' Naive Bayes classifier for texts
#' 
#' Fit a multinomial or Bernoulli Naive Bayes model, given a dfm and some
#' training labels.
#' @param x the \link{dfm} on which the model will be fit.  Does not need to contain 
#'   only the training documents.
#' @param y vector of training labels associated with each document identified 
#'   in \code{train}.  (These will be converted to factors if not already 
#'   factors.)
#' @param smooth smoothing parameter for feature counts by class
#' @param prior prior distribution on texts; one of \code{"uniform"},
#'   \code{"docfreq"}, or \code{"termfreq"}.  See Prior Distributions below.
#' @param distribution count model for text features, can be \code{multinomial} 
#'   or \code{Bernoulli}.  To fit a "binary multinomial" model, first convert the 
#'   dfm to a binary matrix using \code{\link{tf}(x, "boolean")}.
#' @param ... more arguments passed through
#' @return A list of return values, consisting of (where \eqn{I} is the total
#'   number of documents, \eqn{J} is the total numebr features, and \eqn{k} is
#'   the total number of training classes):
#' @return \item{call}{original function call}
#' @return \item{PwGc}{\eqn{k \times J}; probability of the word given the class (empirical 
#'   likelihood)}
#' @return \item{Pc}{\eqn{k}-length named numeric vector of class prior probabilities}
#' @return \item{PcGw}{\eqn{k \times J}; posterior class probability given the word}
#' @return \item{Pw}{\eqn{J \times 1}; baseline probability of the word}
#' @return \item{data}{list consisting of the \eqn{I \times J} training dfm
#'   \code{x}, and the \eqn{I}-length \code{y} training class vector}
#' @return \item{distribution}{the distribution argument}
#' @return \item{prior}{the prior argument}
#' @return \item{smooth}{the value of the smoothing parameter}
#' @section Predict Methods: A \code{predict} method is also available for a 
#'   fitted Naive Bayes object, see \code{\link{predict.textmodel_NB_fitted}}.
#' @section Prior distributions:
#' 
#' Prior distributions refer to the prior probabilities assigned to the training
#' classes, and the choice of prior distribution affects the calculation of the
#' fitted probabilities.  The default is uniform priors, which sets the
#' unconditional probability of observing the one class to be the same as
#' observing any other class.
#'
#' "Document frequency" means that the class priors will be taken from the
#' relative proportions of the class documents used in the training set.  This
#' approach is so common that it is assumed in many examples, such as the worked
#' example from Manning, Raghavan, and Schütze (2008) below.  It is not the
#' default in \pkg{quanteda}, however, since there may be nothing informative in
#' the relative numbers of documents used to train a classifier other than the
#' relative availability of the documents.  When training classes are balanced
#' in their number of documents (usually advisable), however, then the
#' empirically computed "docfreq" would be equivalent to "uniform" priors.
#'
#' Setting \code{prior} to "termfreq" makes the priors equal to the proportions
#' of total feature counts found in the grouped documents in each training
#' class, so that the classes with the largest number of features are assigned
#' the largest priors. If the total count of features in each training class was
#' the same, then "uniform" and "termfreq" would be the same.
#' @references Manning, C. D., Raghavan, P., & Schütze, H. (2008). Introduction
#'   to Information Retrieval. Cambridge University Press.
#'   \url{https://nlp.stanford.edu/IR-book/pdf/irbookonlinereading.pdf}
#'   
#'   Jurafsky, Daniel and James H. Martin. (2016) \emph{Speech and Language Processing.}  Draft of November 7, 2016.
#'   \url{https://web.stanford.edu/~jurafsky/slp3/6.pdf}
#' @name textmodel-nb
#' @author Kenneth Benoit
#' @examples
#' ## Example from 13.1 of _An Introduction to Information Retrieval_
#' txt <- c(d1 = "Chinese Beijing Chinese",
#'          d2 = "Chinese Chinese Shanghai",
#'          d3 = "Chinese Macao",
#'          d4 = "Tokyo Japan Chinese",
#'          d5 = "Chinese Chinese Chinese Tokyo Japan")
#' trainingset <- dfm(txt, tolower = FALSE)
#' trainingclass <- factor(c("Y", "Y", "Y", "N", NA), ordered = TRUE)
#'  
#' ## replicate IIR p261 prediction for test set (document 5)
#' (nb.p261 <- textmodel_nb(trainingset, trainingclass, prior = "docfreq"))
#' predict(nb.p261, newdata = trainingset[5, ])
#' 
#' # contrast with other priors
#' predict(textmodel_nb(trainingset, trainingclass, prior = "uniform"))
#' predict(textmodel_nb(trainingset, trainingclass, prior = "termfreq"))
#' 
#' ## replicate IIR p264 Bernoulli Naive Bayes
#' (nb.p261.bern <- textmodel_nb(trainingset, trainingclass, distribution = "Bernoulli", 
#'                               prior = "docfreq"))
#' predict(nb.p261.bern, newdata = trainingset[5, ])
#' @export
textmodel_nb <- textmodel_NB <- function(x, y, smooth = 1, prior = c("uniform", "docfreq", "termfreq"), 
                         distribution = c("multinomial", "Bernoulli"), ...) {
    UseMethod("textmodel_nb")
}

#' @noRd
#' @export
textmodel_nb.dfm <- function(x, y, smooth = 1, prior = c("uniform", "docfreq", "termfreq"), 
                             distribution = c("multinomial", "Bernoulli"), ...) {
    
    x <- as.dfm(x)
    prior <- match.arg(prior)
    distribution <- match.arg(distribution)
    call <- match.call()
    
    y <- factor(y) # no effect if already a factor    
    x.trset <- x[which(!is.na(y)), ]
    y.trclass <- y[!is.na(y)]
    types <- colnames(x)
    docs <- rownames(x)  
    levs <- levels(y.trclass)
    
    ## distribution
    if (distribution == "Bernoulli") {
        x.trset <- tf(x.trset, "boolean")
    } else {
        if (distribution != "multinomial")
            stop("Distribution can only be multinomial or Bernoulli.")
    }
    
    ## prior
    if (prior=="uniform") {
        Pc <- rep(1/length(levs), length(levs))
        names(Pc) <- levs
    } else if (prior=="docfreq") {
        Pc <- prop.table(table(y.trclass))
        Pc_names <- names(Pc)
        attributes(Pc) <- NULL
        names(Pc) <- Pc_names
    } else if (prior=="termfreq") {
        # weighted means the priors are by total words in each class
        # (the probability that any given word is in a particular class)
        temp <- x.trset
        rownames(temp) <- y.trclass
        colnames(temp) <- rep("all_same", nfeature(temp))
        temp <- dfm_compress(temp)
        Pc <- prop.table(as.matrix(temp))
        Pc_names <- rownames(Pc)
        attributes(Pc) <- NULL
        names(Pc) <- Pc_names
    } else stop("Prior must be either docfreq (default), wordfreq, or uniform")
    
    ## multinomial ikelihood: class x words, rows sum to 1
    # combine all of the class counts
    rownames(x.trset) <- y.trclass
    d <- dfm_compress(x.trset, margin = "both")

    if (distribution == "multinomial") {
        PwGc <- rowNorm(d + smooth)
    } else if (distribution == "Bernoulli") {
        # if (smooth != 1) {
        #     warning("smoothing of 0 makes little sense for Bernoulli NB", call. = FALSE, noBreaks. = TRUE)
        # }
        # denominator here is same as IIR Fig 13.3 line 8 - see also Eq. 13.7
        PwGc <- (d + smooth) / (as.vector(table(docnames(x.trset))[docnames(d)]) + smooth * ndoc(d))
        PwGc <- as(PwGc, "dgeMatrix")
    }
    
    
    # order Pc so that these are the same order as rows of PwGc
    Pc <- Pc[rownames(PwGc)]

    ## posterior: class x words, cols sum to 1
    PcGw <- colNorm(PwGc * base::outer(Pc, rep(1, ncol(PwGc))))  
    
    ## P(w)
    Pw <- t(PwGc) %*% as.numeric(Pc)
    
    ll <- list(call = call, 
               PwGc = as.matrix(PwGc), 
               Pc = Pc, 
               PcGw = as.matrix(PcGw), 
               Pw = as.matrix(Pw), 
               data = list(x = x, y = y), 
               distribution = distribution, prior = prior, smooth = smooth)
    class(ll) <- c("textmodel_NB_fitted", class(ll))
    return(ll)
}


#' prediction method for Naive Bayes classifier objects
#'
#' implements class predictions using trained Naive Bayes examples 
#' @param object a fitted Naive Bayes textmodel 
#' @param newdata dfm on which prediction should be made
#' @param ... not used
#' @return A list of two data frames, named \code{docs} and \code{words} corresponding
#' to word- and document-level predicted quantities
#' @return \item{docs}{data frame with document-level predictive quantities: 
#' nb.predicted, ws.predicted, bs.predicted, PcGw, wordscore.doc, bayesscore.doc, 
#' posterior.diff, posterior.logdiff.  Note that the diff quantities are currently 
#' implemented only for two-class solutions.}
#' @return \item{words}{data-frame with word-level predictive quantities: 
#' wordscore.word, bayesscore.word}
#' @author Kenneth Benoit
#' @rdname predict.textmodel
#' @examples 
#' (nbfit <- textmodel_nb(data_dfm_lbgexample, c("A", "A", "B", "C", "C", NA)))
#' (nbpred <- predict(nbfit))
#' @keywords internal textmodel
#' @export
predict.textmodel_NB_fitted <- function(object, newdata = NULL, ...) {
    
    call <- match.call()
    if (is.null(newdata)) newdata <- as.dfm(object$data$x)

    # remove any words for which zero probabilities exist in training set --
    # would happen if smooth=0
    # the condition assigns the index of zero occurring words to vector "notinref" and only 
    # trims the objects if this index has length>0
    if (length(notinref <- which(colSums(object$PwGc)==0))) {
        object$PwGc <- object$PwGc[-notinref]
        object$PcGw <- object$PcGw[-notinref]
        object$Pw   <- object$Pw[-notinref]
        object$data$x <- object$data$x[, -notinref]
        newdata <- newdata[, -notinref] 
    }

    
    # make sure feature set is ordered the same in test and training set (#490)
    if (ncol(object$PcGw) != ncol(newdata))
        stop("feature set in newdata different from that in training set")
    if (!identical(colnames(object$PcGw), colnames(newdata)) | setequal(colnames(object$PcGw), colnames(newdata))) {
        # if feature names are the same but diff order, reorder
        newdata <- newdata[, colnames(object$PcGw)]
    } else {
        stop("feature set in newdata different from that in training set")
    }
    
    if (object$distribution == "multinomial") {
        
        # log P(d|c) class conditional document likelihoods
        log.lik <- newdata %*% t(log(object$PwGc))
        # weight by class priors
        log.posterior.lik <- t(apply(log.lik, 1, "+", log(object$Pc)))
        
    } else if (object$distribution == "Bernoulli") {
        
        newdata <- tf(newdata, "boolean")
        Nc <- length(object$Pc)
        
        # initialize log posteriors with class priors
        log.posterior.lik <- matrix(log(object$Pc), byrow = TRUE, ncol = Nc, nrow = nrow(newdata),
                                    dimnames = list(rownames(newdata), names(object$Pc)))
        # APPLYBERNOULLINB from IIR Fig 13.3
        for (c in seq_len(Nc)) {
            tmp1 <- log(t(newdata) * object$PwGc[c, ])
            tmp1[is.infinite(tmp1)] <- 0
            tmp0 <- log(t(!newdata) * (1 - object$PwGc[c, ]))
            tmp0[is.infinite(tmp0)] <- 0
            log.posterior.lik[, c] <- 
                log.posterior.lik[, c] + colSums(tmp0) + colSums(tmp1)
        }
        
    } 

    
    # predict MAP class
    nb.predicted <- colnames(log.posterior.lik)[apply(log.posterior.lik, 1, which.max)]
    
    ## now compute class posterior probabilities
    # initialize posterior probabilities matrix
    posterior.prob <- matrix(NA, ncol = ncol(log.posterior.lik), 
                             nrow = nrow(log.posterior.lik),
                             dimnames = dimnames(log.posterior.lik))

    # compute posterior probabilities
    for (j in seq_len(ncol(log.posterior.lik))) {
        base.lpl <- log.posterior.lik[, j]
        posterior.prob[, j] <- 1 / (1 + rowSums(exp(log.posterior.lik[, -j, drop = FALSE] - base.lpl)))
    }

    result <- list(log.posterior.lik = log.posterior.lik, 
                   posterior.prob = posterior.prob, 
                   nb.predicted = nb.predicted, 
                   Pc = object$Pc, 
                   classlabels = names(object$Pc), 
                   call = call)
    class(result) <- c("textmodel_NB_predicted", class(result))
    result
}

# not used any more
logsumexp <- function(x) {
    xmax <- which.max(x)
    log1p(sum(exp(x[-xmax] - x[xmax]))) + x[xmax]
}

# @rdname print.textmodel
#' @export
#' @method print textmodel_NB_fitted
print.textmodel_NB_fitted <- function(x, n=30L, ...) {
    cat("Fitted Naive Bayes model:\n")
    cat("Call:\n\t")
    print(x$call)
    cat("\n")
    
    cat("\nTraining classes and priors:\n")
    print(x$Pc)
    
    cat("\n\t\t  Likelihoods:\t\tClass Posteriors:\n")
    print(head(t(rbind(x$PwGc, x$PcGw)), n))
    
    cat("\n")
}


# @param x for print method, the object to be printed
# @param n max rows of dfm to print
# @param digits number of decimal places to print for print methods
# @param ... not used in \code{print.textmodel_wordscores_fitted}

#' @export
#' @method print textmodel_NB_predicted
print.textmodel_NB_predicted <- function(x, n = 30L, digits = 4, ...) {
    
    cat("Predicted textmodel of type: Naive Bayes\n")
    # cat("Call:\n\t")
    # print(x$call)
    if (nrow(x$log.posterior.lik) > n)
        cat("(showing", n, "of", nrow(x$docs), "documents)\n")
    cat("\n")
    
    docsDf <- data.frame(x$log.posterior.lik, x$posterior.prob, x$nb.predicted)
    names(docsDf) <- c(paste0("lp(", x$classlabels, ")"),
                       paste0("Pr(", x$classlabels, ")"),
                       "Predicted")
    k <- length(x$classlabels)
    docsDf[, 1:k] <- format(docsDf[, 1:k], nsmall = digits) #digits = digits + 6)
    docsDf[, (k+1):(2*k)] <- round(docsDf[, (k+1):(2*k)], digits) #, digits = digits)
    docsDf[, (k+1):(2*k)] <- format(docsDf[, (k+1):(2*k)], nsmall = digits) #, digits = digits)
    
    # add a whitespace column for visual padding
    docsDf <- cbind(docsDf[, 1:k], " " = rep("  ", nrow(docsDf)), docsDf[, (k+1):(2*k+1)])
    
    print(docsDf[1:(min(n, nrow(docsDf))), ], digits = digits)
    cat("\n")
}


## some helper functions

## make rows add up to one
rowNorm <- function(x) {
    x / outer(rowSums(x), rep(1, ncol(x)))
}

## make cols add up to one
colNorm <- function(x) {
    x / outer(rep(1, nrow(x)), colSums(x))
}

