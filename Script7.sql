with fb_google as (
  select
    fabd.ad_date,
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
  where ad_date is not null
  union all
  SELECT 
    gabd.ad_date,   
  	gabd.campaign_name,
  	gabd.url_parameters,
  	gabd.spend as spend,
  	gabd.impressions as impressions, 
  	gabd.reach as reach,
  	gabd.clicks as clicks,
  	gabd.leads as leads,
  	gabd.value as value
  from google_ads_basic_daily gabd 
  where ad_date is not null
),
 common_tab as (
  select
   (date_trunc('month', ad_date))::date as ad_month,
	lower(case when substring(url_parameters, 'utm_campaign=([^&#$]+)') = 'nan' then null
			else substring(url_parameters, 'utm_campaign=([^&#$]+)') end) as utm_campaign,
	sum(spend) as total_spend,
  	sum(impressions) as total_impressions,
  	sum(clicks) as total_clicks,
  	sum(value) as total_value,
  	round(case when sum(clicks) != 0 then sum(spend)::numeric /sum(clicks) end,2) as CPC,
	round(case when sum(impressions) != 0 then (sum(spend)::numeric  /sum(impressions))*1000 end,2)	 as CPM, 
	round(case when sum(impressions) != 0 then (sum(clicks)::numeric / sum(impressions))*100	end,2)  as CTR,   
	round(case when sum(spend) != 0 then (sum(value)-sum(spend)) /sum(spend)::numeric end,2)	as ROMI 
  from fb_google
  group by 1,2
 ),
 t2 as (
  select 
    t1.ad_month as ad_month,
    t1.utm_campaign as utm_campaign, 
    t1.cpm as cpm,
  	t1.ctr as ctr,
  	t1.romi as romi,
    lag(CPM) over (PARTITION BY utm_campaign order by ad_month)  as prev_CPM,
	lag(CTR) over (PARTITION BY utm_campaign order by ad_month)  as prev_CTR,
	lag(ROMI) over (PARTITION BY utm_campaign order by ad_month)  as prev_ROMI
  from common_tab as t1
)
  select
    t2.*,
    round(case when prev_CPM != 0 then (CPM - prev_CPM) / prev_CPM end,4) as diff_CPM,
    round(case when prev_CTR != 0 then (CTR - prev_CTR) / prev_CTR end,4)  as diff_CTR,
	round(case when prev_ROMI != 0 then (romi - prev_ROMI) / prev_ROMI end,4) as diff_ROMI
  from t2
 order by utm_campaign
;