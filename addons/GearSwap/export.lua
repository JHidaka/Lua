function export_set(options)
	local temp_items,item_list = get_items(),{}
	local targinv,xml
	if #options > 0 then
		for _,v in pairs(options) do
			if v:lower() == 'inventory' then
				targinv = true
			elseif v:lower() == 'xml' then
				xml = true
			end
		end
	end
	
	if not windower.dir_exists(lua_base_path..'data/export') then
		windower.create_dir(lua_base_path..'data/export')
	end
	
	local inv = temp_items['inventory']
	if targinv then
		-- Load the entire inventory
		for _,v in pairs(inv) do
			if v.id ~= 0 then
				if r_items[v.id] then
					item_list[#item_list+1] = {}
					item_list[#item_list].name = r_items[v.id][language]
					item_list[#item_list].slot = 'item'
				else
					add_to_chat(123,'GearSwap: You possess an item that is not in the resources yet.')
				end
			end
			for i = 1,80 do
				if not item_list[i] then
					item_list[i] = {}
					item_list[i].name = 'empty'
					item_list[i].slot = 'item'
				end
			end
		end
	else
		-- Default to loading the currently worn gear.
		local gear = temp_items['equipment']
		for i,v in pairs(gear) do
			if v ~= 0 then
				if r_items[inv[v].id] then
					item_list[slot_map[i]+1] = {}
					item_list[slot_map[i]+1].name = r_items[inv[v].id][language]
					item_list[slot_map[i]+1].slot = i --default_slot_map[inv[v].slot_id]
				else
					add_to_chat(123,'GearSwap: You are wearing an item that is not in the resources yet.')
				end
			end
		end
		for i = 1,16 do
			if not item_list[i] then
				item_list[i] = {}
				item_list[i].name = 'empty'
				item_list[i].slot = default_slot_map[i-1]
			end
		end
	end
	
	if #item_list == 0 then
		add_to_chat(123,'GearSwap: There is nothing to export.')
		return
	else
		local not_empty
		for i,v in pairs(item_list) do
			if v.name ~= 'empty' then
				not_empty = true
				break
			end
		end
		if not not_empty then
			add_to_chat(123,'GearSwap: There is nothing to export.')
			return
		end
	end
	
	local path = lua_base_path..'data/export/'..player.name..os.date(' %H %M %S%p  %y-%d-%m')
	if xml then
		-- Export in .xml
		if windower.file_exists(path..'.xml') then
			path = path..' '..os.clock()
		end
		local f = io.open(path..'.xml','w+')
		f:write('<spellcast>\n  <sets>\n    <group name="exported">\n      <set name="exported">\n')
		for i,v in ipairs(item_list) do
			if v.name ~= 'empty' then
				f:write('        <'..v.slot..'>'..v.name..'</'..v.slot..'>\n')
			end
		end
		f:write('      </set>\n    </group>\n  </sets>\n</spellcast>')
		f:close()
	else
		-- Default to exporting in .lua
		if windower.file_exists(path..'.lua') then
			path = path..' '..os.clock()
		end
		local f = io.open(path..'.lua','w+')
		f:write('sets.exported={\n')
		for i,v in ipairs(item_list) do
			if v.name ~= 'empty' then
				f:write('    '..v.slot..'="'..v.name..'",\n')
			end
		end
		f:write('}')
		f:close()
	end
end