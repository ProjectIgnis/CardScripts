--Mythic Deepth
--Skill activation
--Flip this card over when you activate this Skill.
--Effect
--All Fish, Sea Serpent, Thunder, and Aqua monsters on the field gain 200 ATK/DEF. All Machine and Pyro monsters on the field lose 200 ATK/DEF. This card's name becomes "Umi" while on the field.
local s,id=GetID()
function s.initial_effect(c)
	aux.AddFieldSkillProcedure(c,2,false)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e3)
	--Atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
	--Def
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	--change name
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_CHANGE_CODE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetValue(22702055)
	c:RegisterEffect(e6)
end
function s.val(e,c)
	local r=c:GetRace()
	if bit.band(r,RACE_FISH+RACE_SEASERPENT+RACE_THUNDER+RACE_AQUA)>0 then return 200
	elseif bit.band(r,RACE_MACHINE+RACE_PYRO)>0 then return -200
	else return 0 end
end
