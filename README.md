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

## References

- https://www.youtube.com/watch?v=y6XCebnB9gs
- https://github.com/dreamsofautonomy/dotfiles/