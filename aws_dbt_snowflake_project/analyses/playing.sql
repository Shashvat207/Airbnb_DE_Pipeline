{% set flag=2%}

select *
from {{ref('bookings')}}
{% if flag == 1 %}
where nights_booked>1
{% else %} 
where nights_booked=1
{% endif %}