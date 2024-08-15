with Fb as (
  select fabd.ad_date,
  		 fc.campaign_name,
  		 fabd.url_parameters,
  		 coalesce(fabd.spend,0) as spend,
  		 coalesce(fabd.impressions,0) as impressions, 
  		 coalesce(fabd.reach,0) as reach,
  		 coalesce(fabd.clicks,0) as clicks,
  		 coalesce(fabd.leads,0) as leads,
  		 coalesce(fabd.value,0) as value
  from facebook_ads_basic_daily fabd 
   left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id
),
google as (
  SELECT gabd.ad_date,   
  		 gabd.campaign_name,
  		 gabd.url_parameters,
  		 coalesce(gabd.spend,0) as spend,
  		 coalesce(gabd.impressions,0) as impressions, 
  		 coalesce(gabd.reach,0) as reach,
  		 coalesce(gabd.clicks,0) as clicks,
  		 coalesce(gabd.leads,0) as leads,
  		 coalesce(gabd.value,0) as value
   from google_ads_basic_daily gabd 
 ),
common_tab as (
  select *
  from fb
  union all
  select * 
  from google
)
select  ad_date,
		campaign_name,
		lower(case when substring(url_parameters, 'utm_campaign=([^&#$]+)') = 'nan' then null
			else substring(url_parameters, 'utm_campaign=([^&#$]+)') end) as utm_campaign,
	    sum(spend) as total_spend,
  	    sum(impressions) as total_impressions,
  	    sum(clicks) as total_clicks,
  	    sum(value) as total_value,
  	    case when sum(clicks)>0 then sum(spend)::numeric /sum(clicks) else -1 end				     as CPC,
	    case when sum(impressions)>0 then (sum(spend)::numeric  /sum(impressions))*1000 else -1 end	 as CPM, 
	    case when sum(impressions)>0 then (sum(clicks)::numeric / sum(impressions))*100	else -1 end  as CTR,   
	    case when sum(spend)>0 then (sum(value)-sum(spend)) /sum(spend)::numeric else -1 end		 as ROMI 
from common_tab
where ad_date is not null
group by 1,2,3
order by ad_date desc
;
-------bonus------------
CREATE OR REPLACE FUNCTION pg_temp.decode_url_part(p varchar) RETURNS varchar AS $$
select
  convert_from(CAST(E'\\x' || string_agg(CASE WHEN length(r.m[1]) = 1 THEN encode(convert_to(r.m[1], 'SQL_ASCII'), 'hex') ELSE substring(r.m[1] from 2 for 2) END, '') AS bytea), 'UTF8')
FROM regexp_matches($1, '%[0-9a-f][0-9a-f]|.', 'gi') AS r(m);
$$ LANGUAGE SQL IMMUTABLE STRICT;
select 
  	ad_date,
	url_parameters,
	lower(substring(decode_url_part(url_parameters) , 'utm_campaign=([^\&]+)')) as campaign,
	case
		when lower(substring(url_parameters, 'utm_campaign=([^\&]+)')) != 'nan' 
					then lower(substring(decode_url_part(url_parameters) , 'utm_campaign=([^\&]+)'))
	end as utm_campaign_fixed
from facebook_ads_basic_daily fabd
;