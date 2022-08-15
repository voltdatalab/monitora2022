## code to prepare `candidatas` dataset goes here

voltutils::autenticar_gsheets()
sheets_candidatas <- googlesheets4::as_sheets_id(
  "1yx7CD9pevhRTCXWrmkffG89hph6TagUWvkh2sUA9Zuk"
)
dados_candidates <- sheets_candidatas |>
  googlesheets4::sheet_names() |>
  purrr::discard(~stringr::str_detect(.x, "dinâmica")) |>
  purrr::map_dfr(~googlesheets4::read_sheet(sheets_candidatas, sheet = .x)) |>
  janitor::clean_names()

token <- rtweet::rtweet_app(Sys.getenv("TW_TOKEN"))
rtweet::auth_as(token)

usernames <- dados_candidates |>
  dplyr::pull(twitter) |>
  stringr::str_extract("(?<=twitter.com/).+") |>
  stringr::str_remove("[\\?\\/].*") |>
  purrr::discard(is.na)

get_user_id <- function(username) {
  message(username)
  id <- username |>
    tolower() |>
    rtweet::search_users() |>
    dplyr::mutate(screen_name = tolower(screen_name)) |>
    dplyr::filter(screen_name == tolower(username)) |>
    dplyr::distinct(id) |>
    dplyr::pull(id)
  if (length(id) == 0) {
    return(0)
  } else {
    return(id)
  }
}

userids <- purrr::map_dbl(usernames, get_user_id)

tbl_userids <- tibble::tibble(
  twitter = usernames, twitter_id = userids
)

dados_candidates <- dados_candidates |>
  dplyr::mutate(
    twitter = stringr::str_extract(twitter, "(?<=twitter.com/).+"),
    twitter = stringr::str_remove(twitter, "[\\?\\/].*"),
    twitter = tolower(twitter)
  ) |>
  dplyr::left_join(tbl_userids, "twitter") |>
  dplyr::mutate(twitter_id = as.character(twitter_id))

usethis::use_data(dados_candidates, overwrite = TRUE)
