# ⚠️ DEPRECATION WARNING ⚠

When I wrote this plugin, the tools for displaying image in the terminal were restricted to ascii. Since then, implementation of the ITerm image protocol has become more widespread. Today, this plugin does not work with most image displaying tools, and I'm not willing to maintain it. This code is here mainly as a reference for myself in the future.

It still works using `tiv` as a client. Though it has a very poor resolution

# text-image.nvim

Quickly and easily display images using only text in a buffer

> If the terminal is so great, why would you ever want to leave it?
>
> — Aristotle, 2023

## Install

You can use your favorite plugin manager. Here's how you'd do it in [Lazy.nvim](https://github.com/folke/lazy.nvim):

```
{
    "Jeansidharta/ascii-image.nvim",
    config = function ()
        require('ascii-image').setup({
            client = "chafa",
            auto_open_on_image = true,
        })
    end
}
```

## Usage

This plugin creates a user command `TextImageOpen`. When called on a buffer that is a image (png, jpeg, svg or gif), it'll display the image on said buffer.

If the `auto_open_on_image` configuration option is set, whenever you open an image buffer, it'll automatically display the image

## Configuration

Default configuration:

```
require("ascii-image").setup({
    client = "__detect",
    auto_open_on_image = false,
})
```

- client (string): The program used to generate the image's ascii representation. If a program is selected, it must be available for execution in the user's PATH environment variable. If `__detect` is provided (the default value), it'll try to find a valid program by itself. Other valid options are:
  - `"chafa"`
  - `"viu"`
  - `"termpix"`
  - `"tiv"`
- auto_open_on_image (bool): If true, it'll automatically display the image whenever a png, jpeg, svg or gif buffers are open
