# Fix chinese input problem of Sublime Text 3 (in Ubuntu)

## Compile shared library

At first, please compile the `libsublime-imfix.c` to shared library:

```bash
gcc -shared -o libsublime-imfix.so sublime_imfix.c  `pkg-config --libs --cflags gtk+-2.0` -fPIC
```

If you get error like `no such file:gtk/gtkimcontext.h`, plesae install `libgtk2.0-dev` package:

```bash
sudo apt-get install libgtk2.0-dev
```

Then, the compile will success (if all goes according to plan), and you get a file `libsublime-imfix.so`.

**If you can't finish the complie anyway, you can try the compiled file I provided, but still recommended to use the self-compiled version.**

## Put files in the right place

```bash
sudo mv libsublime-imfix.so /opt/sublime/
```

## Setup you .desktop file and script

```bash
sudi gedit /usr/share/applications/sublime-text.desktop
```

And do some replacement.

`Exec=/opt/sublime_text/sublime_text %F` ==> `Exec=bash -c "LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so exec /opt/sublime_text/sublime_text %F"`

`Exec=/opt/sublime_text/sublime_text -n` ==> `Exec=bash -c "LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so exec /opt/sublime_text/sublime_text -n"`

`Exec=/opt/sublime_text/sublime_text --command new_file` ==> `Exec=bash -c "LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so exec /opt/sublime_text/sublime_text --command new_file"`

Save the file and then:

```bash
sudo gedit /usr/bin/subl
```

Replace the content with

```bash
#!/bin/sh
LD_PRELOAD=/opt/sublime_text/libsublime-imfix.so exec /opt/sublime_text/sublime_text "$@"
```

## Reference

[解决Linux下 sublime text2输入法问题的方案](https://m.oschina.net/blog/98713)

[Post : "Input method support" On Sublime Forum](http://www.sublimetext.com/forum/viewtopic.php?f=3&t=7006&start=10#p41343)

[Ubuntu下Sublime Text 3解决无法输入中文的方法](http://jingyan.baidu.com/article/f3ad7d0ff8731609c3345b3b.html)

## Finish

2015-06-06

7sDream
