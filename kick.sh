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

echo " ------------ Homebrew ------------"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" < /dev/null
#yes '' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
echo " ------------ END ------------"
# Homebrewをインストールしないと、git使えない


echo " ------------ git ------------"
# gitをインストールする
brew install git
# git認証情報のキャッシュを無効化
git config -l
git config --system --unset credential.helper
git config -l
# 念の為、キーチェーンアクセスからgitの認証情報を削除する
security find-internet-password -s github.com
security delete-internet-password -l github.com
security find-internet-password -s github.com
echo " ------------ END ------------"

echo " ------------ init ------------"
gitClone "git clone https://github.com/gsx-lab/init.git"
pushd init
#chmod -v u+x init.sh
# ./init.sh
popd
echo " ------------ END ------------"
