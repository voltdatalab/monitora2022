CREATE OR REPLACE FUNCTION azmina_monitora.p_mod_raca(datum timestamp without time zone DEFAULT (CURRENT_DATE - '7 days'::interval), datum2 timestamp without time zone DEFAULT CURRENT_DATE, retw boolean DEFAULT NULL::boolean, OUT data_tweet date, OUT raca text, OUT qtd_tweets numeric, OUT perc_total numeric, OUT total numeric, OUT qtd_tweets_off numeric, OUT perc_total_off numeric, OUT total_off numeric)
 RETURNS SETOF record
 LANGUAGE plpgsql
AS $function$
begin
	RETURN query
with total_data_raca as (
SELECT    cast(t.created_at - interval '3 hours' AS date) AS data_tweet,
          p.raca                                        AS raca,
          cast(count(DISTINCT t.status_id) AS numeric)    AS qtd_tweets,
          cast(count(DISTINCT o.status_id) AS numeric)      AS qtd_tweets_off
FROM      azmina_monitora.tweets t
LEFT JOIN azmina_monitora.perfis p on p.journalist = ANY(t.journalist)
LEFT JOIN azmina_monitora.tweets_ofensivos o on t.status_id = o.status_id
WHERE     t.created_at - interval '3 hours' BETWEEN cast((datum) AS timestamp)
											AND 	cast((datum2) AS timestamp) + interval '23 hours 59 minutes 59 seconds'
AND       (retw IS NULL OR t.is_retweet = retw)
GROUP BY  cast(t.created_at - interval '3 hours' AS date),p.raca
),
total_dia AS(
         select	distinct cast(created_at - interval '3 hours' AS date)    AS data_tweet,
				cast(count(DISTINCT x.status_id) AS       numeric) AS qtd_tweets,
				cast(count(DISTINCT o.status_id) AS numeric)      AS qtd_tweets_off
         FROM     azmina_monitora.tweets x
         LEFT JOIN azmina_monitora.tweets_ofensivos o on x.status_id = o.status_id
         WHERE    x.created_at - interval '3 hours' BETWEEN cast((datum) AS timestamp)
         												AND cast((datum2) AS timestamp) + interval '23 hours 59 minutes 59 seconds'
		AND      (retw IS NULL OR x.is_retweet = retw)
         GROUP BY cast(x.created_at - interval '3 hours' AS date)
         )
select
	total_data_raca.data_tweet,
	total_data_raca.raca,
	total_data_raca.qtd_tweets,
	total_dia.qtd_tweets as total_dia,
	case total_dia.qtd_tweets
		when 0 then 0
		else cast( total_data_raca.qtd_tweets /
	          total_dia.qtd_tweets AS numeric) * 100.00
	end AS perc_total,
	total_data_raca.qtd_tweets_off,
	total_dia.qtd_tweets_off as total_dia_off,
	case total_dia.qtd_tweets_off
		when 0 then 0
		else cast( total_data_raca.qtd_tweets_off /
	          total_dia.qtd_tweets_off AS numeric) * 100.00
	end AS perc_total_off
from total_data_raca
join total_dia on total_data_raca.data_tweet = total_dia.data_tweet
order by data_tweet,qtd_tweets desc;
 END;
$function$
;
