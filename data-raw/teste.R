cand <- dados_candidates$twitter[1] |>
  (\(x) paste0("@", x))()

token <- rtweet::rtweet_app(Sys.getenv("TW_TOKEN"))
rtweet::auth_as(token)


teste <- rtweet::search_tweets(
  q = paste(cand, "-tweet.fields=referenced_tweets"),
  n = Inf,
  token = token,
  retryonratelimit = TRUE
)

teste2 <- rtweet::search_tweets(
  q = cand,
  n = Inf,
  token = token,
  retryonratelimit = TRUE
)

teste <- readr::read_rds("data-raw/teste.rds")

dplyr::glimpse(teste)
dplyr::glimpse(teste2)

teste |>
  dplyr::filter(!stringr::str_detect(full_text, cand)) |>
  dplyr::pull(id) |>
  purrr::pluck(1) |>
  format(scientific = FALSE)
  dplyr::pull(full_text)

?rtweet::get_retweets()


teste2 |>
  dplyr::filter(!stringr::str_detect(text, cand))
