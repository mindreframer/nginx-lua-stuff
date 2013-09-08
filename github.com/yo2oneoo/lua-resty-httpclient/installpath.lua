if not arg or not arg[1] then
  io.write("Usage: lua installpath.lua modulename\n")
  os.exit(1)
end
for p in string.gmatch(package.cpath, "[^;]+") do
  if string.sub(p, 1, 1) ~= "." then
    io.write(p:sub(1, p:find('?')-1)..arg[1], "\n")
    return
  end
end
error("no suitable installation path found")
