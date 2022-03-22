# Scripts and snippets to do cool things with OSM

## `osm2gif.fish`: Render before and after gifs from multiple `.osm` files with Map Machine

Dependancies: [`map-machine`](https://github.com/enzet/map-machine), [`inkscape`](https://inkscape.org/), [ImageMagick](https://imagemagick.org/), [`fish` shell](https://fishshell.com/).

```sh
./osm2gif.fish -b-31.9568321,115.8137405,-31.9557898,115.8162671 before.osm between.osm after.osm -p "jualbup lake"
```

