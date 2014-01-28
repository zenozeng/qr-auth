#!/bin/bash

sid="yVCCkhQotJJcWWwICEi83Z9u"
hash="f1c8e629aee1adb2c1635cd8d6608b93ba4b4b34ef7a0664baa39e0eac3ba040bdcc9367657d3724280c24c5e12a6766f8422ff673742ca77ffadaf1900e8a8c"
curl -d "username=zenozeng&hash=$hash&sid=$sid" "http://localhost:3000/"
