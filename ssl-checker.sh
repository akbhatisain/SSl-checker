#!/bin/bash
# IF you want Email notification fill the below details and uncomment line 44 to 47. 
# Email configuration
TO_EMAIL="your@email.com"
FROM_EMAIL="your@email.com"
SMTP_SERVER="smtp.yourmailprovider.com"
SMTP_PORT="587"
SMTP_USER="your@email.com"
SMTP_PASS="your_email_password"

# Function to check SSL certificate expiration
check_ssl_expiry() {
  domain="$1"
  expiration_date=$(openssl s_client -connect "${domain}:443" -servername "${domain}" 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)

  expiry_timestamp=$(date -d "${expiration_date}" +%s)
  current_timestamp=$(date +%s)
  days_remaining=$(( (expiry_timestamp - current_timestamp) / 86400 ))

  echo "${domain}: ${days_remaining} days remaining"

  if [ ${days_remaining} -eq 7 ]; then
    send_email "${domain}" "${days_remaining}" "first"
  elif [ ${days_remaining} -eq 2 ]; then
    send_email "${domain}" "${days_remaining}" "second"
  fi
}

# Function to send email notification
send_email() {
  domain="$1"
  days_remaining="$2"
  subject="SSL Certificate Expiry Warning for ${domain}"
  urgency="$3"

  if [ "${urgency}" == "first" ]; then
    body="The SSL certificate for ${domain} will expire in ${days_remaining} days."
  elif [ "${urgency}" == "second" ]; then
    body="URGENT: The SSL certificate for ${domain} will expire in ${days_remaining} days. Take immediate action!"
  else
    return
  fi

#  echo -e "Subject:${subject}\n\n${body}" | \
#    mail -s "${subject}" -r "${FROM_EMAIL}" -S smtp="${SMTP_SERVER}:${SMTP_PORT}" \
#    -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="${SMTP_USER}" \
#    -S smtp-auth-password="${SMTP_PASS}" -S from="${FROM_EMAIL}" "${TO_EMAIL}"
}

# List of your domains which you want to check.
DOMAINS=("ibm.com" "facebook.com" "google.com")

# Loop through each domain and check SSL expiry
for domain in "${DOMAINS[@]}"; do
  check_ssl_expiry "${domain}"
done
