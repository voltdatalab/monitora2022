
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

# sql_terms <- readr::read_file("inst/terms.sql")
# update_ofensivos(sql_terms)

# tweets <- tweets |>
#   dplyr::mutate(
#     ofensivo = stringr::str_detect(full_text, rx),
#     termos_ofensivos = stringr::str_extract_all(full_text, rx)
#   )

# voltutils::autenticar_gsheets()
# tweets |>
#   dplyr::filter(ofensivo) |>
#   dplyr::mutate(termos_ofensivos = purrr::map_chr(
#     termos_ofensivos, ~ stringr::str_c(unique(.x), collapse = ", ")
#   )) |>
#   dplyr::transmute(full_text, candidata = perfil, termos_ofensivos) |>
#   googlesheets4::write_sheet(
#     googlesheets4::as_sheets_id("1i3IQtoYvmrbUewm-21PqVY9Ypo3yYgasDaY0yUqomFA"),
#     "amostra_ofensivos"
#   )
