#!/bin/bash
openssl bf -e -kfile key -in rc -out rc.enc && rm rc
