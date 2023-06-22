local ws, err = http.websocket("wss://your-websocket-server-url")

if ws then
  print("WebSocket server connected")

  while true do
    local message = ws.receive()

    if message then
      -- Process the received command
      local response = processCommand(message)

      -- Send the response back to the client
      ws.send(response)
    end
  end

  ws.close()
  print("WebSocket server disconnected")
else
  print("Failed to connect to the WebSocket server: " .. err)
end

function processCommand(command)
  -- Add your own logic here to process the command
  -- and generate the appropriate response

  -- Example: If the command is "ping", respond with "Pong!"
  if command == "ping" then
    return "Pong!"
  end

  -- Example: If the command is "time", respond with the current time
  if command == "time" then
    return os.time()
  end

  -- Default response for unknown commands
  return "Unknown command"
end
