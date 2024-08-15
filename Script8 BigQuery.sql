/* Створи запит для отримання таблиці з інформацією про події, користувачів та сесії в GA4.
  В результаті виконання запиту ми маємо отримати таблицю, що включатиме в себе такі поля:
event_timestamp - дата та час події (тип даних має бути timestamp).
user_pseudo_id - анонімний ідентифікатор користувача в GA4
session_id - ідентифікатор сесії подій в GA4
event_name - назва події
country - країна користувача сайту
device_category - категорія пристрою користувача сайту
source - джерело відвідування сайту
medium - medium відвідування сайту
campaign - назва кампанії відвідування сайту

Таблиця має включати лише дані за 2021 рік, та дані з таких подій:
Початок сесії на сайті
Перегляд товару
Додавання товару до корзини
Початок оформлення замовлення
Додавання інформації про доставку
Додавання платіжної інформації
Покупка*/
select
   datetime(timestamp_micros(event_timestamp)) as event_timestamp,
   user_pseudo_id,
   (select value.int_value from table_info.event_params where key = 'ga_session_id') as session_id,
   event_name,
   geo.country as country,
   device.category as device_category,
   traffic_source.source as source,
   traffic_source.medium as medium,
   traffic_source.name as campaign
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` as table_info
where event_name in ('session_start', 'view_item', 'add_to_cart', 'begin_checkout', 'add_shipping_info', 'add_payment_info', 'purchase')
 and _table_suffix between '20200101' and '20201231'
limit 1000
;