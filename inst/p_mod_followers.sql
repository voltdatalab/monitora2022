CREATE OR REPLACE FUNCTION azmina_monitora.p_mod_followers(datum timestamp without time zone DEFAULT (CURRENT_DATE - '7 days'::interval), datum2 timestamp without time zone DEFAULT CURRENT_DATE, retw boolean DEFAULT NULL::boolean, OUT journalist text, OUT followers_count integer, OUT qtd_tweets bigint, OUT razao_tweets_followers numeric, OUT qtd_tweets_off bigint, OUT razao_tweets_followers_off numeric)
 RETURNS SETOF record
 LANGUAGE plpgsql
AS $function$
begin
	RETURN query
select distinct p.journalist,
				p.followers_count,
				count(distinct t.status_id) as qtd_tweets,
				cast(cast(count(distinct t.status_id) as numeric) / cast(p.followers_count as numeric) as numeric) * 100.0 as razao_tweets_followers,
				count(distinct o.status_id) as qtd_tweets_off,
				cast(cast(count(distinct o.status_id) as numeric) / cast(p.followers_count as numeric) as numeric) * 100.0 as razao_tweets_off_followers
from azmina_monitora.tweets t
left join azmina_monitora.perfis p on p.journalist = any(t.journalist)
LEFT JOIN azmina_monitora.tweets_ofensivos o on t.status_id = o.status_id
WHERE     t.created_at - interval '3 hours' BETWEEN cast((datum) AS timestamp)
											AND 	cast((datum2) AS timestamp) + interval '23 hours 59 minutes 59 seconds'
AND       (retw IS null OR t.is_retweet = retw)
group by p.journalist, p.followers_count
order by razao_tweets_followers desc
;
 END;
$function$
;
