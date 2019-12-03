# Chisel

Chisel is a library that uses bitmap fonts to scuplt text on any device that can handle pixels.

## Usage

1. Take a function to draw pixels...

```elixir
  put_pixel = fn x, y ->
    thing.draw_pixel(x, y, ...)
  end
```

2. Pick a BDF font (Look for one on the Internet or take one from the fixtures folder on this project)

```elixir
  {:ok, font} = Chisel.Font.load("foo/bar/font.bdf")
```

3. Use Chisel to sculpt the text using the provided function and font

```elixir
  Chisel.Renderer.draw_text("Hello World!", x, y, font, put_pixel)
```

4. Enjoy!

![Demo](images/demo.jpg)

(Thanks to [lawik](https://github.com/lawik) for the picture)

