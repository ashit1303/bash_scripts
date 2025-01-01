# Reduce image size in bulk
# set folder names

target_dir=./yourFolder
new_dir=./newFolder
i=1
for entry in "$target_dir"/*.jpg
do
  echo "$entry"
  filename=$(basename "$entry")
  convert $entry -resize 20% ./$new_dir/$filename
  ((i=i+1))
done
