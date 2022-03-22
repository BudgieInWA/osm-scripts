#!/usr/bin/env fish
# This script calls osm-ba

function osm-ba --description 'Render a gif cycling through different .osm files using osm-render.fish and convert'
  # usage: osm-ba -b-31.9568,115.8137,-31.9557,115.8162 before.osm between after.osm -p "jualbup lake"

  # Validate args.
  # TODO allow passing arbitrary args to osm-render.
  argparse -N 2 'b/bbox=' 'p/prefix=' 'z/zoom=' -- $argv; or return
  if test -z "$_flag_bbox"; echo (status current-function)": -b/--bbox is required"; return 1; end
  if test -z "$_flag_zoom"; set _flag_zoom 18; end
  set -l files $argv

  # Render each file to png.
  for file in $files
    osm-render --prefix="$_flag_prefix" "$file" --bbox="$_flag_bbox" -- -z "$_flag_zoom" --labels no; or return
  end

  # Calculate filenames for the last step.
  set -l pngs (for f in $files; replace-ext png (prefix-filename "$_flag_prefix" "$f"); end)
  set -l names (for f in $files; replace-ext "" (basename "$f"); end)
  set -l out (prefix-filename "$_flag_prefix" (string join "-" $names)".gif")

  echo "Combining rasters to $out..."
  convert -dispose previous -delay 200 $pngs $out
end

function osm-render --description 'Render a .osm file to .svg with map-machine and .png with inkscape'
  # usage: osm-render shenton-park.osm -- --label no

  # Validate args.
  argparse -N 1 'b/bbox=' 'p/prefix=' -- $argv; or return
  set -l file $argv[1]
  set -l render_args $argv[2..-1]

  # Convert lat,lon to lon,lat
  set -l b ""
  if test -n "$_flag_bbox"
    set -l ll (string split , -- "$_flag_bbox")
    set b "$ll[2]","$ll[1]","$ll[4]","$ll[3]"
  end

  # Calculate filenames
  set -l out (prefix-filename "$_flag_prefix" "$file")
  set -l svg (replace-ext svg "$out")
  set -l png (replace-ext png "$out")

  echo "Loading $file..."
  map-machine render -i "$file" -o "$svg" -b="$b" $render_args; or return
  echo "Rasterising to $png..."
  inkscape --without-gui "$svg" -e "$png"
end

function replace-ext --argument ext file
  set -l base (string split --right --max 1 . "$file")[1]
  if test -z $ext
    echo "$base"
  else
    echo "$base.$ext"
  end
end

function prefix-filename --argument prefix file
  if test -z $prefix
    echo "$file"
  else
    echo (dirname "$file")"/$prefix-"(basename $file)
  end
end

osm-ba $argv
