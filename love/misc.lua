function love.threaderror(thread, errorstr)
   io.write('THREAD ERROR (', tostring(thread), '): ', errorstr, "\n")
end
