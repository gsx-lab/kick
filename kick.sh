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


echo " ------------ nmap ------------"
#* nmap
# * nmap v7.70をインストールする
# * brewのnmap(v7.80)にはnmap-scriptにバグがあるため(Refs #12692)
brew info nmap
nmap -v
pushd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula
git checkout 7032494f15 nmap.rb
# brewで更新されないように設定してインストール
HOMEBREW_NO_AUTO_UPDATE=1 brew install nmap
brew info nmap
nmap -v
# Formulaのバージョンはもとに戻しておく
git reset --hard
popd
echo " ------------ END ------------"

echo " ------------ init ------------"
gitClone "git clone https://github.com/gsx-lab/init.git"
pushd init
#chmod -v u+x init.sh
# ./init.sh
popd
echo " ------------ END ------------"
