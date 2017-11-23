from gevent import monkey
monkey.patch_all()

import hug
import json
import base64
import yaml


def http_response(data=None, status=200, message='Success', code=0):
    return {
        'meta': {
            'code': code,
            'status': status,
            'message': message,
        },
        'data': data,
    }


def not_found_handler():
    return http_response(status=404, message='api not found!')

hug.not_found()(not_found_handler)


def get_config(name):
    with open(name) as f:
        return yaml.safe_load(f)


@hug.get('/subscribe', output=hug.output_format.html)
def get_subscribe(token):
    subscribe_config = get_config('subscribes.yml')
    if token not in subscribe_config['tokens']:
        return http_response(status=403, message='access forbidden')

    server_list_raw = "\r\n".join(subscribe_config['servers'])
    response_raw = "MAX={max_config}\r\n{server_list_raw}".format(
        max_config=subscribe_config['max_config'],
        server_list_raw=server_list_raw,
    )

    b64_data = base64.b64encode(response_raw.encode('utf-8'))
    return b64_data.decode('utf-8')
