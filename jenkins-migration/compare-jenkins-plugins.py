#!/usr/bin/env python


import xml.etree.ElementTree as ET
from distutils.version import LooseVersion, StrictVersion
from argparse import ArgumentParser

"""
  Plugin compare tool to list plugins differences between two jenkins instance by plugin xml.
  Need to get plugin installed xml using this: http://${jenkins}/pluginManager/api/xml?depth=1
"""

class PluginInfo(object):
    def __init__(self, shortName, longName, version):
        self.shortName = shortName
        self.longName = longName
        self.version = version

    def __str__(self):
        return 'shortName: "%s", longName: "%s", version: "%s"' % (self.shortName, self.longName, self.version)

    def __eq__(self, other):
        return isinstance(other, self.__class__) and self.shortName == other.shortName and self.version == other.version

    def __ne__(self, other):
        return (not self.__eq__(other))

    def __hash__(self):
        return hash(self.shortName) ^ hash(self.version)

    __repr__ = __str__

def run(target_xml, source_xml):
    root_base = ET.parse(target_xml).getroot()
    allPis_base = generate_plugins(root_base)
    root_compare = ET.parse(source_xml).getroot()
    allPis_compare = generate_plugins(root_compare)
    installed = []
    others = []
    need_upgraded = []
    not_installed = []
    allPis_base_names = set(map(lambda x: x.shortName, allPis_base))
    for pi in allPis_compare:
        if pi in allPis_base:
            installed.append(pi)
        else:
            for pi_base in allPis_base:
                if pi_base.shortName == pi.shortName and version_compare(pi_base.version, pi.version):
                    need_upgraded.append(pi)

        if pi.shortName not in allPis_base_names:
            not_installed.append(pi)

    print_result(target_xml, source_xml, installed, need_upgraded, not_installed)

def parse_args():
  parser = ArgumentParser()
  parser.add_argument('target_jenkins_plugins_xml_file', type=str,
                   help='The target jenkins plugins xml result file which will be migrated to')
  parser.add_argument('source_jenkins_plugins_xml_file', type=str,
                   help='The source jenkins plugins xml result file which will be migrated from')

  args = parser.parse_args()
  return args.target_jenkins_plugins_xml_file, args.source_jenkins_plugins_xml_file



def generate_plugins(root):
    allPis = set()
    for atype in root.findall('plugin'):
        if atype.find('active').text == 'true' and atype.find('enabled').text == 'true':
            allPis.add(PluginInfo(atype.find('shortName').text, atype.find('longName').text, atype.find('version').text))
    return allPis

def version_compare(v1, v2):
    return LooseVersion(v1) < LooseVersion(v2)

def print_result(target_xml, source_xml,installed, need_upgraded, not_installed):
    print 'both installed:'
    for pi in installed:
        print '    %s' % pi

    print 'not installed on %s but on %s:' % (target_xml, source_xml)
    for pi in not_installed:
        print '    %s' % pi

    print 'need upgrade on %s:' % target_xml
    for pi in need_upgraded:
        print '    %s' % pi

if __name__ == '__main__':
    target_xml,source_xml = parse_args()
    run(target_xml, source_xml)
