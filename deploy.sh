#!/bin/bash

# Stop bij fouten
set -e

# Eerst upstream changes ophalen
git pull origin main --rebase

# Alles toevoegen en committen met datum + tijd
git add .
git commit -m "Daily update: $(date '+%Y-%m-%d %H:%M')" || echo "✅ Geen wijzigingen om te committen"

# Push naar main
git push origin main
