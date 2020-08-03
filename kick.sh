#!/usr/bin/env bash -x

# bash -c "$(curl -L https://raw.githubusercontent.com/gsx-lab/kick/master/init.sh)"

# Usage
if [ $# -ne 0 ]; then
  echo "Usage: `basename $0`" 1>&2
  exit 1
fi

# func
function gitClone() {
  expect -c "
    set timeout 3600
    spawn $1
    expect {
        \"fatal: destination path \" {
            exit 0
        }
        \"Username for \" {
            send -- \"${gitId}\n\"
            expect \"Password for \"
            send -- \"${gitPw}\n\"
            interact  # これないとgit cloneされない
        }
    }
  "
}

# 変数
read -p "GitのUsernameを入力してください: " gitId
read -sp "GitのPasswordを入力してください: " gitPw

echo " ------------ init ------------"
gitClone "git clone https://github.com/gsx-lab/init.git"
pushd init
#chmod -v u+x init.sh
./init.sh
popd
echo " ------------ END ------------"
