CREATE OR REPLACE FUNCTION azmina_monitora.p_mod_journalist(datum timestamp without time zone DEFAULT (CURRENT_DATE - '7 days'::interval), datum2 timestamp without time zone DEFAULT CURRENT_DATE, retw boolean DEFAULT NULL::boolean, OUT raca text, OUT qtd_tweets numeric, OUT perc_total numeric, OUT total numeric, OUT qtd_tweets_off numeric, OUT perc_total_off numeric, OUT total_off numeric)
 RETURNS SETOF record
 LANGUAGE plpgsql
AS $function$
begin
	RETURN query
WITH total AS
(
       SELECT cast(Count(DISTINCT x.status_id) as numeric) AS qtd_tweets,
       cast(Count(DISTINCT x.status_id) as numeric) AS qtd_tweets_off
       FROM   azmina_monitora.tweets x
       LEFT JOIN azmina_monitora.tweets_ofensivos o on x.status_id = o.status_id
       WHERE  x.created_at - interval '3 hours' BETWEEN cast((datum) AS timestamp) AND    cast((datum2) AS timestamp) + interval '23 hours 59 minutes 59 seconds'
       and (retw IS null or x.is_retweet = retw)
       )
SELECT    p.journalist                    AS journalist,
          cast(count(DISTINCT t.status_id) as numeric) AS qtd_tweets,
          case (SELECT total.qtd_tweets
                 FROM   total)
          when 0 then 0
          else cast(
				cast(count(DISTINCT t.status_id) as numeric) /
				(SELECT total.qtd_tweets
                 FROM   total) AS numeric) * 100.00
           end AS perc_total,
          (SELECT total.qtd_tweets FROM   total) AS total,
          cast(count(DISTINCT o.status_id) as numeric) AS qtd_tweets_off,
		case (SELECT total.qtd_tweets_off
                 FROM   total)
		when 0 then 0
		else cast(cast(count(DISTINCT o.status_id) as numeric) /
				(SELECT total.qtd_tweets_off
                 FROM   total) AS numeric) * 100.00
		end AS perc_total_off,
		(SELECT total.qtd_tweets FROM   total) AS total_off

FROM      azmina_monitora.tweets t
LEFT JOIN azmina_monitora.perfis p ON p.journalist = ANY(t.journalist)
LEFT JOIN azmina_monitora.tweets_ofensivos o on t.status_id = o.status_id
where t.created_at - interval '3 hours' BETWEEN cast((datum) AS timestamp)
AND       cast((datum2) AS timestamp) + interval '23 hours 59 minutes 59 seconds'
and (retw IS null or t.is_retweet = retw)
GROUP BY  p.journalist
order by qtd_tweets DESC;
 END;
$function$
;
