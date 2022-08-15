-- Atualiza propriedades dos tweets existentes em tweet_properties conforme registros trazidos da API do Twitter e gravados em `base`
WITH t
     AS (SELECT Cast(t2.id AS NUMERIC)       AS id,
                Cast(t2.favorite_count AS NUMERIC)  AS favorite_count,
                Cast(t2.retweet_count AS NUMERIC)   AS retweet_count
         FROM   azmina_monitora.tweet_properties b2
                JOIN azmina_monitora.temp t2
                  ON b2.id = Cast(t2.id AS NUMERIC)
         WHERE  b2.id <> Cast(t2.id AS NUMERIC)
                 OR b2.favorite_count <> Cast(t2.favorite_count AS NUMERIC)
                 OR b2.retweet_count <> Cast(t2.retweet_count AS NUMERIC))
UPDATE azmina_monitora.tweet_properties tp
SET    favorite_count = t.favorite_count,
       retweet_count = t.retweet_count
FROM   t
WHERE  tp.id = t.id;

-- Inserindo novas languages
-- insert into azmina_monitora.twitter_langs
-- SELECT Row_number()
-- 		 OVER () + coalesce((select max(lang_id) from azmina_monitora.twitter_langs),0) as id,
-- 	   ltrim(rtrim(x.lang)) as lang_initial
-- FROM   (SELECT DISTINCT b.lang
-- 		FROM   azmina_monitora.temp b
-- 		LEFT JOIN azmina_monitora.twitter_langs tl on rtrim(ltrim(b.lang)) = rtrim(ltrim(tl.lang_initial))
-- 		WHERE  coalesce(b.lang,'') <> ''
-- 		and tl.lang_id is null
-- 		ORDER  BY b.lang) x ;

INSERT INTO azmina_monitora.tweets
WITH j
	 AS (SELECT DISTINCT id,
						 Array_agg(distinct username) AS username
		 FROM   azmina_monitora.temp
		 GROUP  BY id)
SELECT distinct Cast(b.id AS bigint) as id,
	   j.username,
	   Cast(b.user_id   AS bigint) as user_id,
	   Cast(b.created_at AS TIMESTAMP) AS created_at,
	   CASE
			  WHEN b.is_quote_status = 'TRUE' THEN true
			  ELSE false
	   END AS is_quote,
	   CASE
			  WHEN b.is_retweet = 'TRUE' THEN true
			  ELSE false
	   END AS is_retweet,
	   b.full_text AS tweet_text,
	  --  (
		-- 	  SELECT min(lang_id)
		-- 	  FROM   azmina_monitora.twitter_langs
		-- 	  WHERE  lang_initial LIKE b.lang ) AS lang_id,
    b.screen_name
FROM   azmina_monitora.temp b
join j ON b.id = j.id
LEFT JOIN azmina_monitora.tweets t ON Cast(b.id AS bigint) = t.id
WHERE t.id IS null;

-- inserindo novas tweet_properties
insert into azmina_monitora.tweet_properties
SELECT distinct cast(b.id as bigint),
       case when b.favorite_count is null
			then 0
	   else cast(b.favorite_count as int)
	   end as favorite_count,
       case when b.retweet_count is null
			then 0
	   else cast(b.retweet_count as int)
	   end as retweet_count
FROM   azmina_monitora.temp b
LEFT JOIN azmina_monitora.tweet_properties tp on Cast(b.id AS bigint) = tp.id
WHERE  tp.id is  null;