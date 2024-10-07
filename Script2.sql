select ad_date,
	   campaign_id,
	   sum(spend) 						as amt_all_spend,			--загал сума витрат
	   sum(impressions) 					as cnt_impressions, 		--кіл-ть показів
	   sum(clicks) 						as cnt_clicks, 				--кіл-ть кліків
	   sum(value)						as amt_value, 				--загал дохід конверсій
	   sum(spend)::numeric /sum(clicks) 			as CPC,
	   (sum(spend)::numeric  /sum(impressions))*1000 	as CPM, 
	   (sum(clicks)::numeric / sum(impressions))*100	as CTR,   
	   (sum(value)-sum(spend)) /sum(spend)::numeric 		as ROMI
from public.facebook_ads_basic_daily
group by ad_date,campaign_id
having sum(clicks)>0 and sum(impressions)>0 and sum(spend)>0
;


WITH campaign_metrics AS (
    SELECT 
        campaign_id,
        SUM(value) AS amt_value ,
        SUM(spend) AS amt_spend,
        (SUM(value)-SUM(spend))/SUM(spend)::numeric  AS romi 
    FROM 
        facebook_ads_basic_daily
    GROUP BY 
        campaign_id
    HAVING 
        SUM(spend) > 500000						
)
SELECT 
    campaign_id, romi
FROM 
    campaign_metrics
WHERE 
    romi = (SELECT MAX(romi) FROM campaign_metrics) --найвищий romi
;
