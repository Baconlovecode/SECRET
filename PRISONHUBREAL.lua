# PRISONHUBREAL.lua
REAL_LINK = "https://raw.githubusercontent.com/Baconlovecode/SECRET/refs/heads/main/PRISONHUBFAKE.lua?token=GHSAT0AAAAAADPYFVAB5UMU6MQK6LFA62YW2JWV2WQ"

# 1. Header giả (Giao diện đánh lừa)
header = r"""--[[
██████╗  ██████╗ ██████╗ ██████╗ ███████╗
██╔══██╗██╔════╝██╔═══██╗██╔══██╗██╔════╝
██████╔╝██║     ██║   ██║██║  ██║█████╗  
██╔══██╗██║     ██║   ██║██║  ██║██╔══╝  
██████╔╝╚██████╗╚██████╔╝██████╔╝███████╗
╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝

            404: Not Found
--]]"""


void_space = "\n" * 3000


code = f"loadstring(game:HttpGet('https://raw.githubusercontent.com/Baconlovecode/SECRET/refs/heads/main/PRISONHUBFAKE.lua?token=GHSAT0AAAAAADPYFVAB5UMU6MQK6LFA62YW2JWV2WQ'))()"

with open("BCODE_FINAL.lua", "w", encoding="utf-8") as f:
    f.write(header + void_space + code)

print("BCODE_FINAL.lua' Upload file") 