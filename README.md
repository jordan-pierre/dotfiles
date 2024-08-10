 My dotfiles

This directory contains the dotfiles for my system

## Requirements

Ensure you have the following installed on your system

### Git

```
sudo dnf install git
```

### Stow

```
sudo dnf install stow
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```
$ git clone git@github.com/jordan-pierre/dotfiles.git
$ cd dotfiles
```

then use GNU stow to create symlinks

```
$ stow .
```

use the adopt flag if the file already exists
```
$ stow --adopt .
```


### VS Code

I manually made a symbolic link for VS Code because it has so many files in its `.config` and I'm only interested in `settings.json`.
```
mv ~/.config/Code/User/settings.json ~/dotfiles/.config/Code/User/
ln -s ~/dotfiles/.config/Code/User/settings.json ~/.config/Code/User/settings.json
```

## References

- https://www.youtube.com/watch?v=y6XCebnB9gs
- https://github.com/dreamsofautonomy/dotfiles/
