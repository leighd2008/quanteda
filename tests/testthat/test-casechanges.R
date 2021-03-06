library(quanteda)

context("test case change functions")

test_that("toLower works.", {
    expect_equal((char_tolower("According to NATO")), "according to nato")
})

test_that("toLower keeps acronyms.", {
    expect_equal((char_tolower("According to NATO", keep_acronyms = TRUE)), "according to NATO")
})

test_that("char_tolower/char_toUpper works.", {
    expect_equal((char_tolower("According to NATO")), "according to nato")
    expect_equal((char_toupper("According to NATO")), "ACCORDING TO NATO")
})

test_that("char_tolower keeps acronyms.", {
    expect_equal((char_tolower("According to NATO", keep_acronyms = TRUE)), "according to NATO")
})

test_that("tokens_tolower/tokens_toupper works", {
    toksh <- tokens("According to NATO")
    expect_equal((as.list(tokens_tolower(toksh))[[1]]),
                      c("according", "to", "nato"))
    expect_equal((as.list(tokens_toupper(toksh))[[1]]),
                 c("ACCORDING", "TO", "NATO"))
})

test_that("toLower/toUpper.tokenizedTexts works as expected", {
    toksh <- tokenize("According to NATO")
    expect_equal((as.list(tokens_tolower(toksh))[[1]]),
                 c("according", "to", "nato"))
    expect_equal((as.list(tokens_toupper(toksh))[[1]]),
                 c("ACCORDING", "TO", "NATO"))
})

