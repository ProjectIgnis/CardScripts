type=(function()
	local oldf=type
	return function(o)
		local tp=oldf(o)
		if tp~="userdata" then return tp
		elseif o.GetOriginalCode then return "Card"
		elseif o.KeepAlive then return "Group"
		elseif o.SetLabelObject then return "Effect"
		else return "userdata"
		end
	end
end)()

local locations={
	[LOCATION_DECK]='"LOCATION_DECK"',
	[LOCATION_HAND]='"LOCATION_HAND"',
	[LOCATION_MZONE]='"LOCATION_MZONE"',
	[LOCATION_SZONE]='"LOCATION_SZONE"',
	[LOCATION_GRAVE]='"LOCATION_GRAVE"',
	[LOCATION_REMOVED]='"LOCATION_REMOVED"',
	[LOCATION_EXTRA]='"LOCATION_EXTRA"',
	[LOCATION_FZONE]='"LOCATION_FZONE"',
	[LOCATION_PZONE]='"LOCATION_PZONE"'
}

local positions={
	[POS_FACEUP]='"POS_FACEUP"',
	[POS_FACEUP_ATTACK]='"POS_FACEUP_ATTACK"',
	[POS_FACEUP_DEFENSE]='"POS_FACEUP_DEFENSE"',
	[POS_FACEDOWN]='"POS_FACEDOWN"',
	[POS_FACEDOWN_ATTACK]='"POS_FACEDOWN_ATTACK"',
	[POS_FACEDOWN_DEFENSE]='"POS_FACEDOWN_DEFENSE"',
	[POS_ATTACK]='"POS_ATTACK"',
	[POS_DEFENSE]='"POS_DEFENSE"'
}

local types={
	[TYPE_MONSTER]='"TYPE_MONSTER"',
	[TYPE_SPELL]='"TYPE_SPELL"',
	[TYPE_TRAP]='"TYPE_TRAP"',
	[TYPE_NORMAL]='"TYPE_NORMAL"',
	[TYPE_EFFECT]='"TYPE_EFFECT"',
	[TYPE_FUSION]='"TYPE_FUSION"',
	[TYPE_RITUAL]='"TYPE_RITUAL"',
	[TYPE_TRAPMONSTER]='"TYPE_TRAPMONSTER"',
	[TYPE_SPIRIT]='"TYPE_SPIRIT"',
	[TYPE_UNION]='"TYPE_UNION"',
	[TYPE_GEMINI]='"TYPE_GEMINI"',
	[TYPE_TUNER]='"TYPE_TUNER"',
	[TYPE_SYNCHRO]='"TYPE_SYNCHRO"',
	[TYPE_TOKEN]='"TYPE_TOKEN"',
	[TYPE_QUICKPLAY]='"TYPE_QUICKPLAY"',
	[TYPE_CONTINUOUS]='"TYPE_CONTINUOUS"',
	[TYPE_EQUIP]='"TYPE_EQUIP"',
	[TYPE_FIELD]='"TYPE_FIELD"',
	[TYPE_COUNTER]='"TYPE_COUNTER"',
	[TYPE_FLIP]='"TYPE_FLIP"',
	[TYPE_TOON]='"TYPE_TOON"',
	[TYPE_XYZ]='"TYPE_XYZ"',
	[TYPE_PENDULUM]='"TYPE_PENDULUM"',
	[TYPE_SPSUMMON]='"TYPE_SPSUMMON"',
	[TYPE_LINK]='"TYPE_LINK"',
	[TYPE_SKILL]='"TYPE_SKILL"',
	[TYPE_ACTION]='"TYPE_ACTION"',
	[TYPE_PLUS]='"TYPE_PLUS"',
	[TYPE_MINUS]='"TYPE_MINUS"',
	[TYPE_ARMOR]='"TYPE_ARMOR"',
	[TYPE_MAXIMUM]='"TYPE_MAXIMUM"'
}

local attributes={
	[ATTRIBUTE_EARTH]='"ATTRIBUTE_EARTH"',
	[ATTRIBUTE_WATER]='"ATTRIBUTE_WATER"',
	[ATTRIBUTE_FIRE]='"ATTRIBUTE_FIRE"',
	[ATTRIBUTE_WIND]='"ATTRIBUTE_WIND"',
	[ATTRIBUTE_LIGHT]='"ATTRIBUTE_LIGHT"',
	[ATTRIBUTE_DARK]='"ATTRIBUTE_DARK"',
	[ATTRIBUTE_DIVINE]='"ATTRIBUTE_DIVINE"'
}

local races={
	[RACE_WARRIOR]='"RACE_WARRIOR"',
	[RACE_SPELLCASTER]='"RACE_SPELLCASTER"',
	[RACE_FAIRY]='"RACE_FAIRY"',
	[RACE_FIEND]='"RACE_FIEND"',
	[RACE_ZOMBIE]='"RACE_ZOMBIE"',
	[RACE_MACHINE]='"RACE_MACHINE"',
	[RACE_AQUA]='"RACE_AQUA"',
	[RACE_PYRO]='"RACE_PYRO"',
	[RACE_ROCK]='"RACE_ROCK"',
	[RACE_WINGEDBEAST]='"RACE_WINGEDBEAST"',
	[RACE_PLANT]='"RACE_PLANT"',
	[RACE_INSECT]='"RACE_INSECT"',
	[RACE_THUNDER]='"RACE_THUNDER"',
	[RACE_DRAGON]='"RACE_DRAGON"',
	[RACE_BEAST]='"RACE_BEAST"',
	[RACE_BEASTWARRIOR]='"RACE_BEASTWARRIOR"',
	[RACE_DINOSAUR]='"RACE_DINOSAUR"',
	[RACE_FISH]='"RACE_FISH"',
	[RACE_SEASERPENT]='"RACE_SEASERPENT"',
	[RACE_REPTILE]='"RACE_REPTILE"',
	[RACE_PSYCHIC]='"RACE_PSYCHIC"',
	[RACE_DIVINE]='"RACE_DIVINE"',
	[RACE_CREATORGOD]='"RACE_CREATORGOD"',
	[RACE_WYRM]='"RACE_WYRM"',
	[RACE_CYBERSE]='"RACE_CYBERSE"'
}

local link_markers={
	[LINK_MARKER_BOTTOM_LEFT]='"LINK_MARKER_BOTTOM_LEFT"',
	[LINK_MARKER_BOTTOM]='"LINK_MARKER_BOTTOM"',
	[LINK_MARKER_BOTTOM_RIGHT]='"LINK_MARKER_BOTTOM_RIGHT"',
	[LINK_MARKER_LEFT]='"LINK_MARKER_LEFT"',
	[LINK_MARKER_RIGHT]='"LINK_MARKER_RIGHT"',
	[LINK_MARKER_TOP_LEFT]='"LINK_MARKER_TOP_LEFT"',
	[LINK_MARKER_TOP]='"LINK_MARKER_TOP"',
	[LINK_MARKER_TOP_RIGHT]='"LINK_MARKER_TOP_RIGHT"'
}

local function formatProperty(prop,prop_name,table)
	local str=''
	if prop~=0 then
		str=str .. ', "'.. prop_name .. '": [ '
		local need_comma=false
		for _,prop in Auxiliary.BitSplit(prop) do
			if table[prop] then
				if not need_comma then need_comma=true
				else str=str .. ', ' end
				str=str .. table[prop]
			end
		end
		str=str .. ' ]'
	end
	return str
end

local function prettyPrintCardRaw(c,fullInfo)
	local str='{ "code": ' .. c:GetCode() .. ', "original_code": ' ..c:GetOriginalCode()
	local location=c:GetLocation()
	local sequence=c:GetSequence()
	if c:IsLocation(LOCATION_FZONE) then
		location=LOCATION_FZONE
		sequence=0
	elseif c:IsLocation(LOCATION_PZONE) then
		location=LOCATION_PZONE
		if sequence~=6 and sequence>=4 then sequence=1
		else sequence=0 end
	end
	str=str .. ', "controller": ' .. tostring(c:GetControler())
	str=str .. ', "location": ' .. tostring(locations[location])
	str=str .. ', "position": ' .. tostring(positions[c:GetPosition()])
	str=str .. ', "sequence": ' .. tostring(sequence)
	if not fullInfo then
		return str .. ' }'
	end
	str=str .. formatProperty(c:GetType(),'type',types)
	str=str .. formatProperty(c:GetAttribute(),'attribute',attributes)
	str=str .. formatProperty(c:GetRace(),'race',races)
	local monster=c:IsMonster()
	if monster then
		if c:HasLevel() then
			str=str .. ', "level": ' .. c:GetLevel()
		end
		if c:IsType(TYPE_XYZ) then
			str=str .. ', "rank": ' .. c:GetRank()
		end
		if c:IsType(TYPE_LINK) then
			str=str .. ', "link_rating": ' .. c:GetLink()
		end
	end
	str=str .. formatProperty(c:GetLinkMarker(),'link_marker',link_markers)
	if monster then
		str=str .. ', "attack": ' .. c:GetAttack()
		if not c:IsType(TYPE_LINK) then
			str=str .. ', "defense": ' .. c:GetDefense()
		end
	end
	return str .. ' }'
end

function Debug.CardToString(c)
	return 'Card: ' .. prettyPrintCardRaw(c,true)
end

local function prettyPrintGroupRaw(g)
	local len=#g
	local str='{ "size": ' .. len
	if len>0 then
		str=str .. ', "cards": [ '
		local need_comma=false
		for tc in g:Iter() do
			if not need_comma then need_comma=true
			else str=str .. ', ' end
			str=str .. prettyPrintCardRaw(tc,false)
		end
		str=str .. ' ]'
	end
	return str .. ' }'
end

function Group.__tostring(g)
	return 'Group: ' .. prettyPrintGroupRaw(g)
end