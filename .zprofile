export XDG_CONFIG_HOME='/home/kaka/.config'
export RUST_SRC_PATH='/home/kaka/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library'
export NVM_DIR="/home/kaka/.config/nvm"
export LC_ALL=C

export PATH="/home/kaka/.config/nvm/versions/node/v15.0.1/bin:/home/kaka/.gem/ruby/2.7.0/bin:/home/kaka/.cargo/bin:/home/kaka/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/opt/android-sdk/platform-tools"

#### This loads nvm
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" &

# automatically run startx when logging in on tty1
[ -z "$DISPLAY" ] && [ $XDG_VTNR -eq 1 ] && startx
