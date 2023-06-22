local ws, err = http.websocket("wss://your-websocket-server-url")

if ws then
  print("WebSocket server connected")

  -- Send a welcome message to the client
  ws.send("Hello, server!")

  while true do
    local message = ws.receive()

    if message then
      -- Process the received command
      local success, result = pcall(loadstring(message))

      -- Check if the command execution was successful
      if success then
        -- Return the result of the command
        ws.send("Command executed successfully: " .. tostring(result))
      else
        -- Return the error message if command execution failed
        ws.send("Command execution error: " .. tostring(result))
      end
    end
  end

  ws.close()
  print("WebSocket server disconnected")
else
  print("Failed to connect to the WebSocket server: " .. err)
end
