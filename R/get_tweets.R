get_tweets <- function(username, token, ...) {
  message(username)
  db <- db_connect()
  last_status <- DBI::dbGetQuery(
    db, paste0(
      "SELECT created_at, id FROM azmina_monitora.base2022 ",
      "WHERE username = '", username,
      "' ORDER BY created_at DESC LIMIT 1"
    )
  ) |>
    dplyr::pull(id)
  pool::poolClose(db)
  if (length(last_status) == 0) {
    last_status <- "1559226013304889344"
  } else {
    last_status <- as.character(last_status)
  }

  rtweet::auth_as(token)
  user_tweets <- rtweet::search_tweets(
    q = paste0("@", username),
    n = Inf,
    since_id = last_status,
    retryonratelimit = TRUE,
    lang = "pt",
    ...
  )
  if (nrow(user_tweets) > 0) {
    user_tweets <- user_tweets |>
      dplyr::select(
        created_at:full_text, source,
        is_quote_status:retweeted
      ) |>
      dplyr::mutate(
        username = username, social = "twitter",
        is_retweet = stringr::str_detect(full_text, "^RT ")
      )
    user_data <- user_tweets |>
      rtweet::users_data() |>
      dplyr::transmute(
        user_id = id, user_id_str = id_str, name, screen_name, location,
        description, url, protected, followers_count, friends_count,
        listed_count, verified, statuses_count, profile_image_url_https,
        profile_banner_url, default_profile, default_profile_image
      )
    user_tweets <- dplyr::bind_cols(user_data, user_tweets)
  } else {
    user_tweets <- NULL
  }
  return(user_tweets)
}
