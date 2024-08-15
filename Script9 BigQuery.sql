/*Розрахунок конверсій в розрізі дат та каналів трафіку
Створи запит для отримання таблиці з інформацією про конверсії від початку сесії до покупки.
Результуюча таблиця має включати в себе такі поля:
event_date - дата старту сесії, що отримана з поля event_timestamp
source - джерело відвідування сайту
medium - medium відвідування сайту
campaign - назва кампанії відвідування сайту
user_sessions_count - кількість унікальних сесій в унікальних користувачів у відповідну дату та для відповідного каналу трафіку.
visit_to_cart - конверсія від початку сесії на сайті до додавання товару в корзину (у відповідну дату та для відповідного каналу трафіку)
visit_to_checkout - конверсія від початку сесії на сайті до спроби оформити замвовлення (у відповідну дату та для відповідного каналу трафіку)
Visit_to_purchase - конверсія від початку сесії на сайті до покупки (у відповідну дату та для відповідного каналу трафіку)
Примітка 
Зверни увагу, що різні користувачі можуть мати однакові ідентифікатори сесій. 
Тому щоб порахувати унікальні сесії унікальних користувачів, треба враховувати не тільки ідентифікатор сесії, а й ідентифікатор користувача.
*/
with t1 as (
  select
   date(timestamp_micros(event_timestamp)) as event_date,
   event_name,
   concat(user_pseudo_id, 
          cast((select value.int_value from table_info.event_params where key = 'ga_session_id')as string)) as user_session_id,
   traffic_source.source as source,
   traffic_source.medium as medium,
   traffic_source.name   as campaign
  from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as table_info
  group by 1,2,3,4,5,6
  limit 1000
)
 select
   event_date,
   source,
   medium,
   campaign,
   count(distinct user_session_id) as user_sessions_count, -- кількість унікальних сесій в унікальних користувачів у відповідну дату та для відповідного каналу трафіку
   count(distinct case when event_name = 'add_to_cart' then user_session_id end) / count(distinct user_session_id) as visit_to_cart, -- конверс від поч сесії на сайті до додав тов в корзину
   count(distinct case when event_name = 'begin_checkout' then user_session_id end) / count(distinct user_session_id) as isit_to_checkout, -- конверсія від поч сесії на сайті до спроби оформити замвовлення   
   count(distinct case when event_name = 'purchase' then user_session_id end) / count(distinct user_session_id) as visit_to_purchase  -- конверсія від початку сесії на сайті до покупки  
 from t1
 group by 1,2,3,4
 order by 5 desc
;