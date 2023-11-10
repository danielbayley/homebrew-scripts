#! /bin/zsh --no-rcs --err-exit --aliases
zparseopts -D -E -- h=help -help=help s=series -series=series

if (($#help)) then
  cat $0:h:h:h/README.md
  return
fi

source /etc/profile
source <(brew shellenv)

alias print='echo;print'

alias -g softwareupdate='sudo ${=SUDO_ASKPASS:+--askpass} softwareupdate --install --all --agree-to-license --background'
system() softwareupdate
alias {,mac}os{,x}=system sys=system

# Homebrew
mas() command mas upgrade

alias formula{e,}='brew --formulae'
alias cask{s,}='brew --cask'

brew() {
  print "Brewing"
  command brew update
  command brew upgrade $@
  command brew install-bundler-gems

  # Update git submodules.
  for repo in $HOMEBREW_REPOSITORY/Library/Taps/*/*(/)
  do git -C $repo submodule update --recursive --remote
  done

  # Update Homebrew RubyGems
  command brew ruby -e 'Homebrew.install_bundler_gems!'
}

if (($+commands[anka])) then
  alias v{eertu,m}=anka
  anka() {
    ANKA_TABLE_FMT=plain command anka list --field name | while read
    do command anka start --update-addons $REPLY
    done
  }
fi

alias ruby{gems,}=gem rb=gem gems=gem
gem() {
  print "Updating RubyGems"
  command gem update --install-dir=$GEM_HOME
}

alias npm=$commands[(I)*npm]
if (($#aliases[npm])) npm() {
  print "Updating npm"
  npm update --global
}

alias apm=$commands[(I)apm*]
if (($#aliases[apm])) atom() {
  print "Updating Atom"
  apm update --no-confirm
}

if (($+commands[code])) then
  alias code=vscode
  vscode() {
    print "Updating VS Code"
    command code --list-extensions | while read
    do command code --install-extension $REPLY --force
    done
  }
fi

if ((${#@:#-*})) then
  whence ${@:#-*} | while read
  do echo $=REPLY ${${series:+ }:-&}
  done
else
  skip=()
  whence ${${(M)@:#-*}//-/} | while read
  do skip+=$REPLY
  done

  egrep -o "(${(@kj | )functions:|skip})\(\)" < $0 | while read
  do echo ${=REPLY:0:-2} ${${series:+ }:-&}
  done
fi
