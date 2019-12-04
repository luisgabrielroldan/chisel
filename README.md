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

![Demo](images/demo-inky.jpg)

(Thanks to [lawik](https://github.com/lawik) for the picture)

## General purpose

Chisel is a general purpose library that can be used to render text on any target based on pixels (LCD, Led matrixs, image files, ...).

### Render on an image with `:egd`

```elixir
  img = :egd.create(200, 50)
  color = :egd.color({0, 0, 0})

  put_pixel = fn x, y ->
    :egd.line(img, {x, y}, {x, y}, color)
  end

  {:ok, font} = Chisel.Font.load("font.bdf")

  Chisel.Renderer.draw_text("Hello World!", 0, 0, font, put_pixel)

  :egd.save(:egd.render(img, :png), "test.png")
```

### Render ASCII art

```elixir
  {:ok, agent} = Agent.start_link(fn -> [] end)

  put_pixel = fn x, y ->
    Agent.update(agent, fn pixels ->
      [{x, y} | pixels]
    end)
  end

  {:ok, font} = Chisel.Font.load("c64.bdf")

  Chisel.Renderer.draw_text("Hello World!", 0, 0, font, put_pixel)

  pixels = Agent.get(agent, & &1)

  Agent.stop(agent)

  for y <- 0..10 do
    for x <- 0..100 do
      if Enum.member?(pixels, {x, y}) do
        "%"
      else
        " "
      end
    end
    |> IO.puts()
  end
```

Result:
```
                                                                                                     
                                                                                                     
 %%  %%                                          %%   %%                                   %%        
 %%  %%           %%%     %%%                    %%   %%                  %%%        %%    %%        
 %%  %%   %%%%     %%      %%     %%%%           %%   %%  %%%%   %%%%%     %%        %%    %%        
 %%%%%%  %%  %%    %%      %%    %%  %%          %% % %% %%  %%  %%  %%    %%     %%%%%    %%        
 %%  %%  %%%%%%    %%      %%    %%  %%          %%%%%%% %%  %%  %%        %%    %%  %%              
 %%  %%  %%        %%      %%    %%  %%          %%% %%% %%  %%  %%        %%    %%  %%              
 %%  %%   %%%%    %%%%    %%%%    %%%%           %%   %%  %%%%   %%       %%%%    %%%%%    %%        
                                                                                                     
                                                                                                     
```

### Samples using [OLED](https://github.com/pappersverk/oled)

![OLED Demo](images/demo-oled.jpg)
