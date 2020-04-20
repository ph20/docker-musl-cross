#!/usr/bin/env python
import os
import subprocess

IMAGE_NAME = 'ph20/musl-cross:20200419'
USER_ID = os.geteuid()
GROUP_ID = os.getegid()
DOCKER_BIN = 'docker'
BUIDL_DIR_INSIDE_DOCKER = '/build'


def main(script_path, proj_path):

    cmd = '{docker} --rm -it -v $(pwd):/output -v {proj}:{build} {image} {build}/{recipe}'.format(
        docker=DOCKER_BIN,
        image=IMAGE_NAME,
        proj=proj_path,
        build=BUIDL_DIR_INSIDE_DOCKER,
        recipe=script_path
    )
    os.system(cmd)