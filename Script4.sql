with Fb as (
  select fabd.ad_date,   
  		 fc.campaign_name,
  		 fa.adset_name,
  		 fabd.spend,
  		 fabd.impressions,
  		 fabd.reach,
  		 fabd.clicks,
  		 fabd.leads,
  		 fabd.value,
  		 'Facebook Ads' as media_source
  from facebook_ads_basic_daily fabd 
  left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
  left join facebook_adset fa on fabd.adset_id = fa.adset_id
 ),
google as (
  SELECT gabd.ad_date,   
  		 gabd.campaign_name,
  		 gabd.adset_name,
  		 gabd.spend,
  		 gabd.impressions,
  		 gabd.reach,
  		 gabd.clicks,
  		 gabd.leads,
  		 gabd.value,
 		 'Google Ads' as media_source
  from google_ads_basic_daily gabd 
 ),
campaign_all as (
  select *
  from fb
  union all
  select * 
  from google
 )
select ad_date,
		media_source,
		campaign_name,
		adset_name,
		sum(spend) as total_spend,
  		sum(impressions) as total_impressions,
  		sum(clicks) as total_clicks,
  		sum(value) as total_value
from campaign_all
where ad_date is not null
group by ad_date, media_source, campaign_name, adset_name 
 ;
 -------bonus----

with Fb as (
  select fabd.ad_date,   
  		 fc.campaign_name,
  		 fa.adset_name,
  		 fabd.spend,
  		 fabd.impressions,
  		 fabd.reach,
  		 fabd.clicks,
  		 fabd.leads,
  		 fabd.value,
  		 'Facebook Ads' as media_source
  from facebook_ads_basic_daily fabd 
  left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
  left join facebook_adset fa on fabd.adset_id = fa.adset_id
 ),
google as (
  SELECT gabd.ad_date,   
  		 gabd.campaign_name,
  		 gabd.adset_name,
  		 gabd.spend,
  		 gabd.impressions,
  		 gabd.reach,
  		 gabd.clicks,
  		 gabd.leads,
  		 gabd.value,
 		 'Google Ads' as media_source
  from google_ads_basic_daily gabd 
 ),
campaign_all as (
  select *
  from fb
  union all
  select * 
  from google
 ),
campaign_metrics as (
    select 
        campaign_name,
        adset_name,
        sum(value) as total_value ,
        sum(spend) as total_spend,
        round((sum(value)-sum(spend))/sum(spend)::numeric*100,2)||'%' as romi 
    from 
        campaign_all
    group by campaign_name, adset_name
    having sum(spend) > 500000						
)
select
    campaign_name,
    adset_name,
    romi as max_romi
from 
    campaign_metrics
where romi = (select MAX(romi) 
			  from campaign_metrics)
;