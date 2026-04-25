{% set cols=['nights_booked','booking_amount','booking_id']%}

SELECT 
{% for col in cols %}
{{col}}
{% if not loop.last %},{% endif %}
{% endfor %}
from {{ref("bookings")}}