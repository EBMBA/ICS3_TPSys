#!/bin/bash
which -a $1 | tail -1 | xargs dpkg -S