with Fb as (
  select ad_date,
  		spend,
  		impressions,
  		reach,
  		clicks,
  		leads,
  		value,
  		'Facebook Ads' as media_source  		
  from facebook_ads_basic_daily fabd 
  where ad_date is not null
),
google as (
  SELECT ad_date,
  		spend,
  		impressions,
  		reach,
  		clicks,
  		leads,
  		value,
  		 'Google Ads' as media_source
  from google_ads_basic_daily gabd 
  where ad_date is not null
),
common_tab as (	
  select * 
  from Fb
  union all
  select * 
  from google
)
select ad_date,
	   media_source,
	   sum(spend) as sum_spend,
  	   sum(impressions) as sum_impressions,
  	   sum(clicks) as sum_clicks,
  	   sum(value) as sum_value
from common_tab
group by ad_date, media_source
;