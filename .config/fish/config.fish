if status is-interactive
    # Alias
    alias ls='lsd'
    alias cat='bat --paging=never'

    # Start starship
    set -x STARSHIP_CONFIG ~/.config/starship/starship.toml
    starship init fish | source

    # Unset fish greeting message
    set -U fish_greeting
end
