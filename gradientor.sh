#!/usr/bin/env bash

########################################
# =====================================#
# Gradientor - Generate easy gradients
# Made by: @butterific
# Dependencies: awk, figlet (for --banner), chafa or timg (for --image)
# =====================================#
########################################

set -u

# cleqr console function
clear_console() {
    printf "\033[2J\033[H"
}


# terminal size function
get_terminal_size() {
    local colls lines
    if command -v tput >/dev/null 2>&1; then
        cols=$(tput cols 2>/dev/null)
        lines=$(tput lines 2>/dev/null)
    fi
    echo "${cols:-80} ${lines:-24}"
}

# random hex

rand_hex() {
    printf "%02x%02x%02x" $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256))
}

# normalize hex color
normalize_hex() {
    local hex="${1#\#}"
    if [[ ! "$hex" =~ ^[0-9a-fA-F]{6}$ ]]; then
        echo "ERR-UNEXPECTED HEX COLOR '$1'. Expected 6 hex digits" >&2
        exit 1
    fi
    echo "$hex"
}

# the main gradient render engine (asisted with ai)
render_gradient_lines() {
    local start_hex end_hex total_width
    start_hex=$(normalize_hex "$1")
    end_hex=$(normalize_hex "$2")
    total_width="$3"

    if (( total_width <= 0 )); then
        return
    fi

    local sr=$((16#${start_hex:0:2}))
    local sg=$((16#${start_hex:2:2}))
    local sb=$((16#${start_hex:4:2}))

    local er=$((16#${end_hex:0:2}))
    local eg=$((16#${end_hex:2:2}))
    local eb=$((16#${end_hex:4:2}))

    awk -v sr="$sr" -v sg="$sg" -v sb="$sb" \
        -v er="$er" -v eg="$eg" -v eb="$eb" \
        -v steps="$total_width" '
    BEGIN {
        if (steps > 1) {
            step_r = (er - sr) / (steps - 1)
            step_g = (eg - sg) / (steps - 1)
            step_b = (eb - sb) / (steps - 1)
        } else {
            step_r = 0; step_g = 0; step_b = 0
        }
    }
    {
        line = $0
        len = length(line)
        out = ""
        for (i = 1; i <= len; i++) {
            ch = substr(line, i, 1)
            if (ch != " ") {
                idx = i - 1
                r = int(sr + step_r * idx)
                g = int(sg + step_g * idx)
                b = int(sb + step_b * idx)
                out = out sprintf("\033[38;2;%d;%d;%dm%s\033[0m", r, g, b, ch)
            } else {
                out = out " "
            }
        }
        print out
    }'
}


