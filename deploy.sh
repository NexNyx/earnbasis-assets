#!/bin/bash
git add .
git commit -m "Daily update: $(date '+%Y-%m-%d %H:%M')"
git push origin main
