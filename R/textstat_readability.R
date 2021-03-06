#' calculate readability
#'
#' Calculate the readability of text(s) using one of a variety of computed 
#' indexes.
#' @param x a character or \link{corpus} object containing the texts
#' @param measure character vector defining the readability measure to calculate.  
#'   Matches are case-insensitive.
#' @param remove_hyphens if \code{TRUE}, treat constituent words in hyphenated as
#'   separate terms, for purposes of computing word lengths, e.g.
#'   "decision-making" as two terms of lengths 8 and 6 characters respectively,
#'   rather than as a single word of 15 characters
#' @param min_sentence_length,max_sentence_length set the minimum and maximum 
#'   sentence lengths (in tokens, excluding punctuation) to include in the
#'   computation of readability.  This makes it easy to exclude "sentences" that
#'   may not really be sentences, such as section titles, table elements, and 
#'   other cruft that might be in the texts following conversion.
#'   
#'   For finer-grained control, consider filtering sentences prior first, 
#'   including through pattern-matching, using \code{\link{corpus_trim}}.
#' @param drop  if \code{TRUE}, the result is returned as a numeric vector if
#'   only a single measure is requested; otherwise, a data.frame is returned
#'   with each column consisting of a requested measure.
#' @param ... not used
#' @author Kenneth Benoit, re-engineered from the function of the same name by
#'   Meik Michalke in the \pkg{koRpus} package.
#' @return a data.frame object consisting of the documents as rows, and the
#'   readability statistics as columns
#' @export
#' @examples
#' txt <- c("Readability zero one.  Ten, Eleven.", "The cat in a dilapidated tophat.")
#' textstat_readability(txt, "Flesch.Kincaid")
#' textstat_readability(txt, "Flesch.Kincaid", drop = FALSE)
#' textstat_readability(txt, c("FOG", "FOG.PSK", "FOG.NRI"))
#' inaugReadability <- textstat_readability(data_corpus_inaugural, "all")
#' round(cor(inaugReadability), 2)
#' 
#' textstat_readability(data_corpus_inaugural, measure = "Flesch.Kincaid")
#' inaugReadability <- textstat_readability(data_corpus_inaugural, "all")
#' round(cor(inaugReadability), 2)
textstat_readability <- function(x,
                        measure = c("all", "ARI", "ARI.simple", "Bormuth", "Bormuth.GP",
                                    "Coleman", "Coleman.C2",
                                    "Coleman.Liau", "Coleman.Liau.grade", "Coleman.Liau.short",
                                    "Dale.Chall", "Dale.Chall.old", "Dale.Chall.PSK",
                                    "Danielson.Bryan", "Danielson.Bryan.2",
                                    "Dickes.Steiwer", "DRP", "ELF", "Farr.Jenkins.Paterson",
                                    "Flesch", "Flesch.PSK", "Flesch.Kincaid",
                                    "FOG", "FOG.PSK", "FOG.NRI", "FORCAST", "FORCAST.RGL",
                                    "Fucks", "Linsear.Write", "LIW",
                                    "nWS", "nWS.2", "nWS.3", "nWS.4", "RIX", "Scrabble",
                                    "SMOG", "SMOG.C", "SMOG.simple", "SMOG.de",
                                    "Spache", "Spache.old", "Strain",
                                    "Traenkle.Bailer", "Traenkle.Bailer.2",
                                    "Wheeler.Smith", "meanSentenceLength", "meanWordSyllables"),
                        remove_hyphens = TRUE,
                        min_sentence_length = 1, 
                        max_sentence_length = 10000,
                        drop = TRUE, ...) {
    UseMethod("textstat_readability")
}

#' @noRd
#' @export
textstat_readability.corpus <- function(x,
                                        measure = c("all", "ARI", "ARI.simple", "Bormuth", "Bormuth.GP",
                                                    "Coleman", "Coleman.C2",
                                                    "Coleman.Liau", "Coleman.Liau.grade", "Coleman.Liau.short",
                                                    "Dale.Chall", "Dale.Chall.old", "Dale.Chall.PSK",
                                                    "Danielson.Bryan", "Danielson.Bryan.2",
                                                    "Dickes.Steiwer", "DRP", "ELF", "Farr.Jenkins.Paterson",
                                                    "Flesch", "Flesch.PSK", "Flesch.Kincaid",
                                                    "FOG", "FOG.PSK", "FOG.NRI", "FORCAST", "FORCAST.RGL",
                                                    "Fucks", "Linsear.Write", "LIW",
                                                    "nWS", "nWS.2", "nWS.3", "nWS.4", "RIX", "Scrabble",
                                           "SMOG", "SMOG.C", "SMOG.simple", "SMOG.de",
                                           "Spache", "Spache.old", "Strain",
                                           "Traenkle.Bailer", "Traenkle.Bailer.2",
                                           "Wheeler.Smith", "meanSentenceLength", "meanWordSyllables"),
                               remove_hyphens = TRUE,
                               min_sentence_length = 1, 
                               max_sentence_length = 10000,
                               drop = TRUE, ...) {
    textstat_readability(texts(x), measure, remove_hyphens,
                         min_sentence_length, max_sentence_length, drop, ...)
}


#' @noRd
#' @export
textstat_readability.character <- function(x,
                                  measure = c("all", "ARI", "ARI.simple", "Bormuth", "Bormuth.GP",
                                                 "Coleman", "Coleman.C2",
                                                 "Coleman.Liau", "Coleman.Liau.grade", "Coleman.Liau.short",
                                                 "Dale.Chall", "Dale.Chall.old", "Dale.Chall.PSK",
                                                 "Danielson.Bryan", "Danielson.Bryan.2",
                                                 "Dickes.Steiwer", "DRP", "ELF", "Farr.Jenkins.Paterson",
                                                 "Flesch", "Flesch.PSK", "Flesch.Kincaid",
                                                 "FOG", "FOG.PSK", "FOG.NRI", "FORCAST", "FORCAST.RGL",
                                                 "Fucks", "Linsear.Write", "LIW",
                                                 "nWS", "nWS.2", "nWS.3", "nWS.4", "RIX", "Scrabble",
                                                 "SMOG", "SMOG.C", "SMOG.simple", "SMOG.de",
                                                 "Spache", "Spache.old", "Strain",
                                                 "Traenkle.Bailer", "Traenkle.Bailer.2",
                                                 "Wheeler.Smith", "meanSentenceLength", "meanWordSyllables"),
                                  remove_hyphens = TRUE,
                                  min_sentence_length = 1, 
                                  max_sentence_length = 10000,
                                  drop = TRUE, ...) {

    addedArgs <- names(list(...))
    if (length(addedArgs))
        warning("Argument", if (length(addedArgs) > 1L) "s " else " ", addedArgs, " not used.", sep = "", noBreaks. = TRUE)

    # check that all measures are legal values
    validMeasures <- c("all", "ARI", "ARI.simple", "Bormuth", "Bormuth.GP",
                       "Coleman", "Coleman.C2",
                       "Coleman.Liau", "Coleman.Liau.grade", "Coleman.Liau.short",
                       "Dale.Chall", "Dale.Chall.old", "Dale.Chall.PSK",
                       "Danielson.Bryan", "Danielson.Bryan.2",
                       "Dickes.Steiwer", "DRP", "ELF", "Farr.Jenkins.Paterson",
                       "Flesch", "Flesch.PSK", "Flesch.Kincaid",
                       "FOG", "FOG.PSK", "FOG.NRI", "FORCAST", "FORCAST.RGL",
                       "Fucks", "Linsear.Write", "LIW",
                       "nWS", "nWS.2", "nWS.3", "nWS.4", "RIX",
                       "Scrabble",
                       "SMOG", "SMOG.C", "SMOG.simple", "SMOG.de",
                       "Spache", "Spache.old", "Strain",
                       "Traenkle.Bailer", "Traenkle.Bailer.2",
                       "Wheeler.Smith",
                       "meanSentenceLength",
                       "meanWordSyllables")
    checkMeasure <- char_tolower(measure) %in% char_tolower(validMeasures)
    if (!all(checkMeasure))
        stop("Invalid measure(s): ", measure[!checkMeasure])
    if ("all" %in% measure)
        measure <- validMeasures[-1]
    measure <- validMeasures[char_tolower(validMeasures) %in% char_tolower(measure)]

    # to avoid "no visible binding for global variable" CHECK NOTE
    textID <- W <- St <- C <- Sy <- W3Sy <- W2Sy <- W_1Sy <- W6C <- W7C <- Wlt3Sy <- W_wl.Dale.Chall <-
        W_wl.Spache <- ARI <- ARI.NRI <- ARI.simple <- Bormuth.GP <- Coleman <- Coleman.C2 <-
        Coleman.Liau.ECP <- Coleman.Liau.grade <- Coleman.Liau.short <- Dale.Chall <- Dale.Chall.old <-
        Dale.Chall.PSK <- Danielson.Bryan <- Danielson.Bryan.2 <- Dickes.Steiwer <- DRP <- ELF <-
        Farr.Jenkins.Paterson <- Flesch <- Flesch.PSK <- Flesch.Kincaid <- FOG <- FOG.PSK <- FOG.NRI <-
        FORCAST <- FORCAST.RGL <- Fucks <- Linsear.Write <- LIW <- nWS <- nWS.2 <- nWS.3 <- nWS.4 <-
        RIX <- SMOG <- SMOG.C <- SMOG.simple <- SMOG.de <- Spache <- Spache.old <- Strain <- Wheeler.Smith <-
        data_char_wordlists <- Bormuth.MC <- Bl <- Traenkle.Bailer <- Traenkle.Bailer.2 <- Bormuth <-
        Coleman.Liau <- meanSentenceLength <- meanWordSyllables <- NULL

    if (is.null(names(x)))
        names(x) <- paste0(quanteda_options("base_docname"), seq_along(x))

    if (!missing(min_sentence_length) | !missing(max_sentence_length)) {
        x <- char_trim(x, 'sentences',
                       min_ntoken = min_sentence_length,
                       max_ntoken = max_sentence_length)
    }
    
    # get sentence lengths - BEFORE lower-casing
    St <- nsentence(x)

    # get the word length and syllable info for use in computing quantities
    x <- char_tolower(x)
    tokenizedWords <- tokens(x, remove_punct = TRUE, remove_hyphens = remove_hyphens)

    # number of syllables
    tmpSyll <- nsyllable(tokenizedWords)
    # replace any NAs with a single count (most of these will be numbers)
    tmpSyll <- lapply(tmpSyll, function(y) { y[is.na(y)] <- 1; y })
    
    # lengths in characters of the words
    wordLengths <- lapply(tokenizedWords, stringi::stri_length)

    # common statistics required by (nearly all) indexes
    textFeatures <- data.table(textID = names(x),
                               W = lengths(tokenizedWords),  # number of words
                               St = St,            # number of sentences
                               C = sapply(wordLengths, sum), # number of characters (letters)
                               Sy = sapply(tmpSyll, sum),    # number of syllables
                               W3Sy = sapply(tmpSyll, function(x) sum(x >= 3)),    # number words with >= 3 syllables
                               W2Sy = sapply(tmpSyll, function(x) sum(x >= 2)),    # number words with >= 2 syllables
                               W_1Sy = sapply(tmpSyll, function(x) sum(x == 1)),   # number words with 1 syllable
                               W6C = sapply(wordLengths, function(x) sum(x >= 6)), # number of words with at least 6 letters
                               W7C = sapply(wordLengths, function(x) sum(x >= 7))) # number of words with at least 7 letters
    textFeatures[, W_wl.Dale.Chall := sapply(tokenizedWords, function(x) sum(!(x %in% data_char_wordlists$dalechall)))]
    textFeatures[, Wlt3Sy := W - W3Sy]   # number of words with less than three syllables

    if (any(c("all", "ARI") %in% measure))
        textFeatures[, ARI := 0.5 * W / St + 4.71 * C / W - 21.43]

    if (any(c("all", "ARI.NRI") %in% measure))
        textFeatures[, ARI.NRI := 0.4 * W / St + 6 * C / W - 27.4]

    if (any(c("all", "ARI.simple") %in% measure))
        textFeatures[, ARI.simple := W / St + 9 * C / W]

    CCS <- 35 # Cloze criterion score, percent as integer
    if (any(c("all", "Bormuth") %in% measure)) {
        textFeatures[, Bormuth := 0.886593 - (0.08364 * C/W) + 0.161911 *
                         (W_wl.Dale.Chall / W)^3 - 0.21401 * (W/St) + 0.000577 * (W/St)^2 - 0.000005 * (W/St)^3]
    }
    if (any(c("all", "Bormuth.GP") %in% measure)) {
        textFeatures[, Bormuth.MC := 0.886593 - (0.08364 * C/W) + 0.161911 *
                         (W_wl.Dale.Chall / W)^3 - 0.21401 * (W/St) + 0.000577 * (W/St)^2 - 0.000005 * (W/St)^3]
        textFeatures[, Bormuth.GP := 4.275 + 12.881 * Bormuth.MC - (34.934 * Bormuth.MC^2) + (20.388 * Bormuth.MC^3) +
                         (26.194 * C - 2.046 * CCS^2) - (11.767 * CCS^3) - (44.285 * Bormuth.MC * CCS) +
                         (97.620 * (Bormuth.MC * CCS)^2) - (59.538 * (Bormuth.MC * CCS)^3)]
        textFeatures[, Bormuth.MC := NULL]
    }

    if (any(c("all", "Coleman") %in% measure))
        textFeatures[, Coleman := 1.29 * (100 * W_1Sy / W) - 38.45]

    if (any(c("all", "Coleman.C2") %in% measure))
        textFeatures[, Coleman.C2 := 1.16 * (100 * W_1Sy / W) + 1.48 * (100 * St / W) - 37.95]

    ## cannot compute Coleman.C3, Coleman.C4 without knowing the number of pronouns or prepositions

    if (any(c("all", "Coleman.Liau") %in% measure))
        textFeatures[, Coleman.Liau   := 141.8401 - 0.214590 * (100 * C / W) + 1.079812 * (100 * St / W)]

    if (any(c("all", "Coleman.Liau.grade") %in% measure)) {
        textFeatures[, Coleman.Liau.ECP   := 141.8401 - 0.214590 * (100 * C / W) + 1.079812 * (100 * St / W)]
        textFeatures[, Coleman.Liau.grade := -27.4004 * Coleman.Liau.ECP / 100 + 23.06395]
        textFeatures[, Coleman.Liau.ECP   := NULL]
    }

    if (any(c("all", "Coleman.Liau.short") %in% measure))
        textFeatures[, Coleman.Liau.short := 5.88 * C / W - 29.6 * St / W - 15.8]

    if (any(c("all", "Dale.Chall") %in% measure))
        textFeatures[, Dale.Chall := 64 - 0.95 * 100 * W_wl.Dale.Chall / W - 0.69 * W / St]

    if (any(c("all", "Dale.Chall.old") %in% measure))
        textFeatures[, Dale.Chall.old := 0.1579 * 100 * W_wl.Dale.Chall / W + 0.0496 * W / St + 3.6365]

    if (any(c("all", "Dale.Chall.PSK") %in% measure))
        textFeatures[, Dale.Chall.PSK := 0.1155 * 100 * W_wl.Dale.Chall / W + 0.0596 * W / St + 3.2672]

    if (any(c("all", "Danielson.Bryan") %in% measure)) {
        textFeatures[, Bl := W - 1]  # could be more accurate if count spaces
        textFeatures[, Danielson.Bryan := (1.0364 * C / Bl) + (0.0194 * C / St) - 0.6059]
        textFeatures[, Bl := NULL]
    }

    if (any(c("all", "Danielson.Bryan.2") %in% measure)) {
        textFeatures[, Bl := W - 1]  # could be more accurate if count spaces
        textFeatures[, Danielson.Bryan.2 := 131.059 - (10.364 * C / Bl) + (0.0194 * C / St)]
        textFeatures[, Bl := NULL]
    }

    if (any(c("all", "Dickes.Steiwer") %in% measure)) {
        TTR <- textstat_lexdiv(dfm(x, verbose = FALSE), measure = "TTR")
        textFeatures[, Dickes.Steiwer := 235.95993 - (73.021 * C / W) - (12.56438 * W / St) - (50.03293 * TTR)]
    }

    if (any(c("all", "DRP") %in% measure)) {
        textFeatures[, Bormuth.MC := 0.886593 - (0.08364 * C/W) + 0.161911 *
                         (W_wl.Dale.Chall / W)^3 - 0.21401 * (W/St) + 0.000577 * (W/St)^2 - 0.000005 * (W/St)^3]
        textFeatures[, DRP := (1 - Bormuth.MC) * 100]
        textFeatures[, Bormuth.MC := NULL]
    }

    if (any(c("all", "ELF") %in% measure))
        textFeatures[, ELF := W2Sy / St]

    if (any(c("all", "Farr.Jenkins.Paterson") %in% measure))
        textFeatures[, Farr.Jenkins.Paterson := -31.517 - 1.015 * W / St + 1.599 * W_1Sy / W]

    if (any(c("all", "Flesch") %in% measure))
        textFeatures[, Flesch := 206.835 - 1.015 * W / St - 84.6 * Sy / W ]

    if (any(c("all", "Flesch.PSK") %in% measure))
        textFeatures[, Flesch.PSK := 0.0778 * W / St + 4.55 * Sy / W - 2.2029]

    if (any(c("all", "Flesch.Kincaid") %in% measure))
        textFeatures[, Flesch.Kincaid := 0.39 * W / St + 11.8 * Sy / W - 15.59]

    if (any(c("all", "meanSentenceLength") %in% measure))
        textFeatures[, meanSentenceLength := W / St]

    if (any(c("all", "meanWordSyllables") %in% measure))
        textFeatures[, meanWordSyllables := Sy / W]

    if (any(c("all", "FOG") %in% measure))
        textFeatures[, FOG := 0.4 * ( W / St + 100 * W3Sy / W )]
        # If the text was POS-tagged accordingly, proper nouns and combinations of only easy words
        # will not be counted as hard words, and the syllables of verbs ending in "-ed", "-es" or
        # "-ing" will be counted without these suffixes.

    if (any(c("all", "FOG.PSK") %in% measure))
        textFeatures[, FOG.PSK := 3.0680 * ( 0.0877 * W / St ) + (0.0984 * 100 * W3Sy / W )]

    if (any(c("all", "FOG.NRI") %in% measure))
        textFeatures[, FOG.NRI := ((( Wlt3Sy + 3 * W3Sy ) / (100 * St / W)) - 3) / 2]

    if (any(c("all", "FORCAST") %in% measure))
        textFeatures[, FORCAST := 20 - (W_1Sy * 150 / W) / 10]

    if (any(c("all", "FORCAST.RGL") %in% measure))
        textFeatures[, FORCAST.RGL := 20.43 - 0.11 * W_1Sy * 150 / W]

    if (any(c("all", "Fucks") %in% measure))
        textFeatures[, Fucks := C / W * W / St]

    if (any(c("all", "Linsear.Write") %in% measure))
        textFeatures[, Linsear.Write := ((100 - (100 * Wlt3Sy)/W) + (3 * 100 * W3Sy / W)) / (100 * St / W)]

    if (any(c("all", "LIW") %in% measure))
        textFeatures[, LIW := (W / St) + (100 * W7C) / W]

    if (any(c("all", "nWS") %in% measure))
        textFeatures[, nWS := 19.35 * W3Sy / W + 0.1672 * W / St + 12.97 * W6C / W - 3.27 * W_1Sy / W - 0.875]

    if (any(c("all", "nWS.2") %in% measure))
        textFeatures[, nWS.2 := 20.07 * W3Sy / W + 0.1682 * W / St + 13.73 * W6C / W - 2.779]

    if (any(c("all", "nWS.3") %in% measure))
        textFeatures[, nWS.3 := 29.63 * W3Sy / W + 0.1905 * W / St - 1.1144]

    if (any(c("all", "nWS.4") %in% measure))
        textFeatures[, nWS.4 := 27.44 * W3Sy / W + 0.2656 * W / St - 1.693]

    if (any(c("all", "RIX") %in% measure))
        textFeatures[, RIX := W7C / St]

    if (any(c("all", "SMOG") %in% measure))
        textFeatures[, SMOG := 1.043 * sqrt(W3Sy * 30 / St) + 3.1291]

    if (any(c("all", "SMOG.C") %in% measure))
        textFeatures[, SMOG.C := 0.9986 * sqrt(W3Sy * 30 / St + 5) + 2.8795]

    if (any(c("all", "SMOG.simple") %in% measure))
        textFeatures[, SMOG.simple := sqrt(W3Sy * 30 / St) + 3]

    if (any(c("all", "SMOG.de") %in% measure))
        textFeatures[, SMOG.de := sqrt(W3Sy * 30 / St) - 2]

    if (any(c("all", "Spache") %in% measure)) {
        # number of words which are not in the Spache word list
        textFeatures[, W_wl.Spache := sapply(tokenizedWords, function(x) sum(!(x %in% data_char_wordlists$spache)))]
        textFeatures[, Spache := 0.121 * W / St + 0.082 * (100 * W_wl.Spache / W) + 0.659]
        textFeatures[, W_wl.Spache := NULL]
    }

    if (any(c("all", "Spache.old") %in% measure)) {
        # number of words which are not in the Spache word list
        textFeatures[, W_wl.Spache := sapply(tokenizedWords, function(x) sum(!(x %in% data_char_wordlists$spache)))]
        textFeatures[, Spache.old := 0.141 * W / St + 0.086 * (100 * W_wl.Spache / W) + 0.839]
        textFeatures[, W_wl.Spache := NULL]
    }

    if (any(c("all", "Strain") %in% measure))
        textFeatures[, Strain := Sy * 1 / (St/3) / 10]

    if (any(c("all", "Traenkle.Bailer") %in% measure)) {
        Wprep <- sapply(tokenizedWords, function(x) sum(x %in% prepositions))  # English prepositions
        Wconj <- sapply(tokenizedWords, function(x) sum(x %in% conjunctions))  # English conjunctions
        textFeatures[, Traenkle.Bailer := 224.6814 - (79.8304 * C / W) - (12.24032 * W / St) - (1.292857 * 100 * Wprep / W)]
    }

    if (any(c("all", "Traenkle.Bailer.2") %in% measure)) {
        Wprep <- sapply(tokenizedWords, function(x) sum(x %in% prepositions))  # English prepositions
        Wconj <- sapply(tokenizedWords, function(x) sum(x %in% conjunctions))  # English conjunctions
        textFeatures[, Traenkle.Bailer.2 := 234.1063 - (96.11069 * C / W) - (2.05444 * 100 * Wprep / W) - (1.02805 * 100 * Wconj / W)]
    }

    #     if (any(c("all", "TRI") %in% measure)) {
    #         Ptn <- lengths(tokens(x, remove_punct = FALSE)) - lengths(tokenizedWords)
    #         Frg <- NA  # foreign words -- cannot compute without a dictionary
    #         textFeatures[, TRI := (0.449 * W_1Sy) - (2.467 * Ptn) - (0.937 * Frg) - 14.417]
    #     }

    if (any(c("all", "Wheeler.Smith") %in% measure))
        textFeatures[, Wheeler.Smith := W / St * (10 * W2Sy) / W]

    Scrabble <- NULL
    if ("Scrabble" %in% measure)
        textFeatures[, Scrabble := nscrabble(x, mean)]

    # return a data.frame of the indexes
    tempIndex <- which(names(textFeatures) == "Wlt3Sy")
    textFeatures <- as.data.frame(textFeatures)
    if (nrow(textFeatures) == 1) drop = FALSE
    ret <- textFeatures[, (tempIndex+1) : ncol(textFeatures), drop = drop]
    if (!is.vector(ret) & !("all" %in% measure)) {
        row.names(ret) <- textFeatures$textID
        ret <- ret[, measure, drop = drop] # put in order of measures specified in call
    } else {
        names(ret) <- textFeatures$textID
    }
    ret
}

conjunctions <- c("for", "and", "nor", "but", "or", "yet", "so")
prepositions <- c("a", "abaft", "abeam", "aboard", "about", "above", "absent", "across", "afore", "after", "against", "along",
                  "alongside", "amid", "amidst", "among", "amongst", "an", "anenst", "apropos", "apud", "around", "as", "aside",
                  "astride", "at", "athwart", "atop", "barring", "before", "behind", "below", "beneath", "beside", "besides",
                  "between", "beyond", "but", "by", "chez", "circa", "ca", "c", "concerning", "despite", "down", "during", "except",
                  "excluding", "failing", "following", "for", "forenenst", "from", "given", "in", "including", "inside", "into",
                  "like", "mid", "midst", "minus", "modulo", "near", "next", "notwithstanding", "o'", "of", "off", "on", "onto",
                  "opposite", "out", "outside", "over", "pace", "past", "per", "plus", "pro", "qua", "regarding", "round", "sans",
                  "save", "since", "than", "through", "thru", "throughout", "thruout", "times", "to", "toward", "towards", "under",
                  "underneath", "unlike", "until", "unto", "up", "upon", "versus", "vs", "v", "via", "vis-a-vis", "with", "within",
                  "without", "worth")


#' @rdname data-internal
#' @details 
#' \code{data_char_wordlists} provides word lists used in some readability indexes; 
#' it is a named list of character vectors where each list element 
#' corresponds to a different readability index.  
#' 
#' These are:
#' \describe{
#' \item{\code{DaleChall}}{The long Dale-Chall list of 3,000 familiar (English) words needed to compute the Dale-Chall Readability Formula.}
#' \item{\code{Spache}}{The revised Spache word list (see Klare 1975, 73) needed to compute the Spache Revised Formula of readability (Spache 1974.}
#' }
#' @references
#' Chall, J. S., & Dale, E.  1995. \emph{Readability Revisited: The New Dale-Chall Readability Formula}. Brookline Books.
#'
#' Klare, G. R. 1975. "Assessing readability." \emph{Reading Research Quarterly} 10(1): 62-102.
#'
#' Spache, G. 1953. "A new readability formula for primary-grade reading materials." \emph{The Elementary School Journal} 53: 410-413.
"data_char_wordlists"

