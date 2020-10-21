export XDG_CONFIG_HOME='/home/abhik/.config'
export RUST_SRC_PATH='/home/abhik/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library'
export NVM_DIR="/home/abhik/.config/nvm"
export LC_ALL=C
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH="/home/abhik/.config/nvm/versions/node/v14.13.0/bin:/home/abhik/.gem/ruby/2.7.0/bin:/home/abhik/.cargo/bin:/home/abhik/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/opt/android-sdk/platform-tools"

# automatically run startx when logging in on tty1
[ -z "$DISPLAY" ] && [ $XDG_VTNR -eq 1 ] && startx
