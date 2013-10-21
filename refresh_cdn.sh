params='{"parameters":[["'$1'"]]}'
curl \
-u 'cacheclearer:546897fd9a7ec6b33ab6e609dc9fc99bf12d45a04cd3b6c301feec6093c851df' \
-d $params \
-D - \
'https://api.softlayer.com/rest/v3/SoftLayer_Network_ContentDelivery_Account/1925/purgeCache'
