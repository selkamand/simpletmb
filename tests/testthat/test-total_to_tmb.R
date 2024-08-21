test_that("multiplication works", {

  expect_equal(mutations_to_tmb(
    total_mutations = 500,
    callable_bases = 1000
  ), 5e+05)

  expect_equal(mutations_to_tmb(
    total_mutations = 500,
    callable_bases = 1000,
    mutations_per = "gigabase"
  ), 5e+08)

  expect_equal(mutations_to_tmb(
    total_mutations = 500,
    callable_bases = 1000,
    mutations_per = "kilobase"
  ), 500)

  expect_equal(mutations_to_tmb(
    total_mutations = c(500, 100),
    callable_bases = 1000),
    c(5e+05, 1e+05))


})
