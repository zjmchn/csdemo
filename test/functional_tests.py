#!/usr/bin/env python
#-*- coding: utf-8 -*-

import unittest
import warnings
import argparse
import requests
import sys
import json
import socket

global options

class DemoTest(unittest.TestCase):

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def _ping_port(self, host, port):
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(1)
            s.connect((host, int(port)))
            s.close()
            return True
        except Exception:
           return False

    def _ping_path(self, host, port, path):
        try:
            if not port: port='80'
            url = 'http://%s:%s%s'% (host, port, path)
            r = requests.get(url)
            if r.status_code == 200:
                return True
            else:
                return False
        except Exception:
            return False

    def test_ping_kafka(self):
        ret = self._ping_port(options.host, '31090')
        self.assertTrue(ret)

    def test_ping_zookeeper(self):
        ret = self._ping_port(options.host, '31081')
        self.assertTrue(ret)

    def test_ping_kibana(self):
        ret = self._ping_path(options.host, '31056','/')
        self.assertTrue(ret)

    def test_ping_es(self):
        ret = self._ping_path(options.host, '31092', '/')
        self.assertTrue(ret)

    def test_ping_kafka_monitor(self):
        ret = self._ping_path(options.host, '31808', '/')
        self.assertTrue(ret)

    def test_show_es_status(self):
        url = 'http://%s:31092/_cluster/health?pretty' % options.host
        r = requests.get(url)
        self.assertEqual(r.status_code, 200)
        result = json.loads(r.text)
        self.assertIn(result['status'], {'yellow','green'})
         
    def test_verify_logstash_index_in_es(self):
        url = 'http://%s:31092/_cat/indices?v' %options.host
        r = requests.get(url)
        self.assertEqual(r.status_code, 200)
        self.assertIn('logstash', r.text)

    @unittest.skip('skip now')
    def test_verify_logstash_messages_in_es(self):
        url = 'http://%s:31092/logstash*/_count?pretty' % options.host
        r = requests.get(url)
        self.assertEqual(r.status_code, 200)
        result = json.loads(r.text)
        self.assertGreater(result['count'], 100)

if __name__ == '__main__':
    import xmlrunner
    parser = argparse.ArgumentParser(description='integration test')
    parser.add_argument('--host', default='127.0.0.1', help='host ip')
    options, args = parser.parse_known_args()
    with warnings.catch_warnings(record=True):
        unittest.main(testRunner=xmlrunner.XMLTestRunner(output='test-reports'), argv=sys.argv[:1] + args)
    
