# -*- coding: utf-8 -*-

from time import gmtime, strftime
import requests


AMAZON_IP_RANGE_JSON = 'https://ip-ranges.amazonaws.com/ip-ranges.json'
# All services are:
#   'CLOUDFRONT', 'CODEBUILD', 'S3', 'EC2', 'ROUTE53', 'ROUTE53_HEALTHCHECKS', 'AMAZON'
BLOCKED_SERVICES = ['CLOUDFRONT', ]

try:
    amazon_ip_ranges_request = requests.get(AMAZON_IP_RANGE_JSON)
except Exception as ex:
    raise ex

amazon_ip_ranges = amazon_ip_ranges_request.json()
amazon_services = set([item['service'] for item in amazon_ip_ranges['prefixes']])

unblocked_service = amazon_services - set(BLOCKED_SERVICES)

unblocked_ip_ranges = []
blocked_ip_ranges = []
for item in amazon_ip_ranges['prefixes']:
    if item['service'] in unblocked_service:
        unblocked_ip_ranges.append(item['ip_prefix'])
    elif item['service'] in BLOCKED_SERVICES:
        blocked_ip_ranges.append(item['ip_prefix'])

unblocked_ip_ranges = set(unblocked_ip_ranges) - set(blocked_ip_ranges)
build_time = strftime("%Y-%m-%d %H:%M:%S", gmtime())

with open('./amazon.cfg', 'w') as unblocked:
    unblocked.write('# Amazon / AS16509 build at {}\n'.format(build_time))
    for item in unblocked_ip_ranges:
        unblocked.write('{}\n'.format(item))

with open('./amazon_blocked.cfg', 'w') as blocked:
    blocked.write('# Amazon / AS16509 build at {}\n'.format(build_time))
    for item in blocked_ip_ranges:
        blocked.write('{}\n'.format(item))
