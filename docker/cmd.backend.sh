#!/bin/sh

# Fix secret key
sed -i "s|00000000000000000000000000000000|${SECRET_KEY}|" backend/settings.py

# Fix postgres settings
sed -i "s|'NAME': 'lk'|'NAME': '${POSTGRES_NAME}'|" backend/settings.py
sed -i "s|'USER': 'vagrant'|'USER': '${POSTGRES_USER}'|" backend/settings.py
sed -i "s|'PASSWORD': ''|'PASSWORD': '${POSTGRES_PASSWORD}'|" backend/settings.py
sed -i "s|'HOST': 'localhost'|'HOST': '${POSTGRES_HOST}'|" backend/settings.py

if [ -z "${EMAIL_SMTP_HOST}" ]; then
    sed -i "s|EMAIL_SMTP_HOST = None|'EMAIL_SMTP_HOST': '${EMAIL_SMTP_HOST}'|" backend/settings.py
fi
if [ -z "${EMAIL_SMTP_USER}" ]; then
    sed -i "s|EMAIL_SMTP_USER = None|'EMAIL_SMTP_USER': '${EMAIL_SMTP_USER}'|" backend/settings.py
fi
if [ -z "${EMAIL_SMTP_PASSWORD}" ]; then
    sed -i "s|EMAIL_SMTP_PASSWORD = None|'EMAIL_SMTP_PASSWORD': '${EMAIL_SMTP_PASSWORD}'|" backend/settings.py
fi
if [ -z "${EMAIL_FROM_DOMAIN}" ]; then
    sed -i "s|EMAIL_FROM_DOMAIN = \"yoursite.com\"|'EMAIL_SMTP_PASSWORD': '${EMAIL_FROM_DOMAIN}'|" backend/settings.py
fi
if [ -z "${SLACK_CLIENT_ID}" ]; then
    sed -i "s|SLACK_CLIENT_ID = \"\"|'SLACK_CLIENT_ID': '${SLACK_CLIENT_ID}'|" backend/settings.py
fi
if [ -z "${SLACK_CLIENT_SECRET}" ]; then
    sed -i "s|SLACK_CLIENT_SECRET = \"\"|'SLACK_CLIENT_SECRET': '${SLACK_CLIENT_SECRET}'|" backend/settings.py
fi

# Fix Redis settings
sed -i "s|redis://localhost:6379/0|${REDIS_URL}|" backend/settings.py

go run devproxy.go 0.0.0.0:9102 gae:9103 &

echo "Migrating database"
python manage.py migrate

celery worker -A backend.celery_app -Q \
  	celery,email,ingestion,archive,gae,slack,itunes,itunesux,itunesfetch,appstore,sessions \
  	-lINFO -B -Ofair --concurrency=1 &

echo "Starting server"
python manage.py runserver 0.0.0.0:${PORT}
