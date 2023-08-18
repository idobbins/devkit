if status is-interactive
    # Commands to run in interactive sessions can go here
end

fish_add_path /opt/homebrew/bin

fish_add_path /Users/idobbins/.yarn/bin
fish_add_path /Users/idobbins/.cargo/bin
fish_add_path /Users/idobbins/go/bin

eval (brew shellenv)

# comment out this line if using warp
starship init fish | source

