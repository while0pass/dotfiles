#!/bin/bash
layout=$(

  gdbus call \
      --session \
      --dest org.gnome.Shell \
      --object-path /org/gnome/Shell \
      --method org.gnome.Shell.Eval \
      'imports.ui.status.keyboard.getInputSourceManager().currentSource.id' \
  | cut -d'"' -f2

)
echo ${layout^^}
