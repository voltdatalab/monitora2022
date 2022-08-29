
tbl_twitter <- monitora2022::dados_candidates |>
  dplyr::select(nome, twitter) |>
  dplyr::distinct() |>
  dplyr::filter(!is.na(twitter))

token <- rtweet::rtweet_app(Sys.getenv("TW_TOKEN"))
rtweet::auth_as(token)


new_tweets <- purrr::map_dfr(
  tbl_twitter$twitter,
  monitora2022:::get_tweets,
  token = token
)

new_tweets_tidy <- new_tweets |>
  dplyr::distinct(id, username, .keep_all = TRUE) |>
  dplyr::select(-dplyr::starts_with("quoted_status"))

sql_update <- readr::read_file("inst/update_monitora.sql")
monitora2022:::upload_tweets(new_tweets_tidy, sql_update)

ofensivos <- readr::read_file("inst/terms_tweets.sql")
monitora2022:::update_ofensivos(ofensivos)

termos <- readr::read_file("inst/terms.sql")
monitora2022:::update_ofensivos(termos)

monitora2022:::drop_temp()
