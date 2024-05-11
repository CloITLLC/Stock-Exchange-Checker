#!/bin/bash

# Function to fetch stock data for a single ticker
fetch_stock_data() {
    local ticker="$1"
    local url="https://query1.finance.yahoo.com/v8/finance/chart/$ticker"

    # Fetch JSON data from Yahoo Finance API
    local json_data=$(curl -s "$url")

    # Extract relevant information from JSON
    local current_price=$(echo "$json_data" | jq -r '.chart.result[0].meta.regularMarketPrice')
    local previous_close=$(echo "$json_data" | jq -r '.chart.result[0].meta.chartPreviousClose')
    local change=$(echo "$json_data" | jq -r '.chart.result[0].meta.regularMarketChange')
    local change_percent=$(echo "$json_data" | jq -r '.chart.result[0].meta.regularMarketChangePercent')
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # Determine color based on price movement
    local color=""
    if (( $(echo "$current_price > $previous_close" | bc -l) )); then
        color="\033[0;32m"  # Green for price increase
    elif (( $(echo "$current_price < $previous_close" | bc -l) )); then
        color="\033[0;31m"  # Red for price decrease
    else
        color="\033[0m"  # No color for no price change
    fi

    # Print data with color
    echo ""
    echo "$ticker - $timestamp"
    echo -e "Price: \033[1m$current_price\t${color}▲\033[0m"  # ▲ symbol for candle
    echo "Change: $change ($change_percent)"
}

# Check if at least one ticker symbol is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <ticker1> <ticker2> ..."
    exit 1
fi

# Main loop
while true; do
    for ticker in "$@"; do
        fetch_stock_data "$ticker"
    done
    sleep 1  # Refresh every second
done
