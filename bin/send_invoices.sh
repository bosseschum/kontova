#!/bin/bash
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
cd /home/bosse/Projects/vereinskasse
rails members:send_invoices >> log/cron.log 2>&1
