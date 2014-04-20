--This code was written by Kilarin (Donald Hines)
--License:CC0, you can do whatever you wish with it.
--The numbers for the modes in the textures for this mode were copied and modified from
--the screwdriver mod by RealBadAngel, Maciej Kasatkin (which were originally liscened
--as CC BY-SA

local mode_text = {
	{"Forward"},
	{"Down"},
	{"Up"}
  }


---
---Function
---

function yaw_in_degrees(player)
  local yaw = player:get_look_yaw()*180/math.pi-90
  while yaw < 0 do yaw=yaw+360 end
  while yaw >360 do yaw=yaw-360 end
  return yaw
  end





--returns a node that has been offset in the indicated direction
--0+z,90-x,180-z,270+x: and <0 down -y,    >360 up +y
--I really could have, and probably should have, done this in radians.
--But I've always liked degrees better.
function offset_pos(posin,yaw)
  print("** offset_pos yaw=",yaw," posin=",pos_to_string(posin))
  local posout = {x=posin.x,y=posin.y,z=posin.z}
  if yaw<0 then                  --DOWN
    posout.y=posout.y-1
  elseif yaw>360 then            --UP
    posout.y=posout.y+1
  elseif yaw>315 or yaw<45 then  --FORWARD
    posout.z=posout.z+1
  elseif yaw<135 then            --RIGHT
    posout.x=posout.x-1
  elseif yaw<225 then            --BACK
    posout.z=posout.z-1
  else                           --LEFT
    posout.x=posout.x+1
  end --yaw
  return posout
end --offset_pos


--because built in pos_to_string doesn't handle nil
function pos_to_string(pos)
  if pos==nil then return "(nil)"
  else return minetest.pos_to_string(pos)
  end --poss==nill
end --pos_to_string


function item_place(stack,player,pointed,inv,idx)
  --local player_name = player:get_player_name()
  --minetest.chat_send_all("--placing pointed.type="..pointed.type.." above "..pos_to_string(pointed.above).." under "..pos_to_string(pointed.under).." stack="..stack:to_string())
  local success
  stack, success = minetest.item_place(stack, player, pointed)
  local strsuccess="false"
  --if success then strsuccess="true:" end
  --minetest.chat_send_all("--placed success="..strsuccess.." stack="..stack:to_string())
  if success then  --if item was placed, put modified stack back in inv
    inv:set_stack("main", idx, stack)
  end --success
  return stack,success
end --item_place



--This function is for use when an explorertool is right clicked
--it finds the inventory item immediatly to the right of the explorertool
--and then places THAT item (if possible)
--
function bridgetool_place(item, player, pointed)
   local player_name = player:get_player_name()  --for chat messages
  --find index of item to right of wielded tool
  --(could have gotten this directly from item I suppose, but this works fine)
  local idx = player:get_wield_index() + 1
  --wielded list is usually 8 wide, but a mod might have changed it, so get wielded width
  local invwidth=9
  --local gwl=player:get_inventory():get_width(player:get_wield_list())
  --if gwl==nil then gwl="nil" end
  --if idx <= invwidth then  --make certain tool was inside the wielded length
  --I'm abandoning checking the inventory width.  The wielded tool is obviously in
  --the wield list, however wide it is, and if you put it in the last wield slot,
  --it will use the material from the first slot in the non wield inventory list.
  --which is intuitive anyway.
  local inv = player:get_inventory()
  local stack = inv:get_stack("main", idx) --stack=stack to right of tool
  if stack:is_empty() then
    minetest.chat_send_player(player_name,"bridge tool: no more material to place in stack to right of bridge tool")
  end --stack:is_empty
  if stack:is_empty()==false and pointed ~= nil then
    local success
    local yaw = yaw_in_degrees(player)  --cause degrees just work better for my brain
    --minetest.chat_send_player(player_name, "gwl="..gwl)
    --------------
    local mode = tonumber(item:get_metadata())
    if not mode then
      item=bridgetool_switchmode(item,player,pointed)
    end
    --minetest.chat_send_player(player_name, "pointed.type="..pointed.type.." above "..pos_to_string(pointed.above).." under "..pos_to_string(pointed.under).." yaw="..yaw.." mode="..mode)
    if pointed.type=="node" and pointed.under ~= nil then
      --all three modes start by placing a block forward in the yaw direction
      --under does not change, but above is altered to point to node forward(yaw) from under
      pointed.above=offset_pos(pointed.under,yaw)
      local holdforward=pointed.above   --store for later deletion in mode 2 and 3
      stack,success=item_place(stack,player,pointed,inv,idx)  --place the forward block
      if not success then
        minetest.chat_send_player(player_name, "bridge tool: unable to place Forward at "..pos_to_string(pointed.above))
      elseif mode==2 or mode==3 then --elseif means successs=true, check Mode up or down
        --mode 2 and 3 then add another block either up or down from the forward block
        --and remove the forward block
        ---move pointed under to the new block you just placed
        pointed.under=pointed.above
        if mode==2 then
          --try to place beneath the new block
          pointed.above=offset_pos(pointed.under,-1)
        else --mode==3
          --try to place above the new block
          pointed.above=offset_pos(pointed.under,999)
        end --mode 2 - 3
        stack,success=item_place(stack,player,pointed,inv,idx)
        if not success then
          minetest.chat_send_player(player_name, "bridge tool: unable to place "..mode_text[mode][1].." at "..pos_to_string(pointed.above))
        end --if not success block 2
      --remove the extra stone whether success on block 2 or not
      minetest.node_dig(holdforward,minetest.get_node(holdforward),player)
      end -- if not success block 1 elseif succes block 1 and mode 2 or 3
    end --pointed.type="node" and pointed.under~=nil
  end --pointed ~= nil
end --function bridgetool_place


function bridgetool_switchmode(item, player, pointed) --pointed is ignored
  local player_name = player:get_player_name()  --for chat messages
  local mode = tonumber(item:get_metadata())
  if not mode then  --if item has not been used and mode not set yet:
     mode=0
     minetest.chat_send_player(player_name, "Left click to change mode between 1:Forward, 2:Down, 3:Up,  Right click to place, uses inventory stack directly to right of bridge tool")
  end
	mode = mode + 1
	if mode > 3 then
		mode = 1
	end
  minetest.chat_send_player(player_name, "bridge tool mode : "..mode.." - "..mode_text[mode][1])
	item:set_name("bridgetool:bridge_tool"..mode)
	item:set_metadata(mode)
  return item
  end



minetest.register_craft({
        output = 'bridgetool:bridge_tool',
  recipe = {
    {'default:steel_ingot', '', 'default:steel_ingot'},
    {'', 'default:steel_ingot', ''},
    {'', 'default:mese_crystal_fragment', ''},
  }
})


  minetest.register_tool("bridgetool:bridge_tool", {
    description = "Bridge Tool",
--    inventory_image = "bridgetool_m1.png",
    inventory_image = "bridgetool_wield.png",
    wield_image = "bridgetool_wield.png^[transformR90",
    on_place = bridgetool_place,
    on_use = bridgetool_switchmode
  })

for i = 1, 3 do
  minetest.register_tool("bridgetool:bridge_tool"..i, {
    description = "Bridge Tool mode "..i,
    inventory_image = "bridgetool_m"..i..".png",
    wield_image = "bridgetool_wield.png^[transformR90",
    on_place = bridgetool_place,
    on_use = bridgetool_switchmode
  })
end
