--W－ウィング・カタパルト
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddUnionProcedure(c,s.filter,true)
	--Atk up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(400)
	e3:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e3)
	--Def up
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_DEFENCE)
	e4:SetValue(400)
	e4:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e4)
end
s.old_union=true
s.listed_names={51638941}
function s.filter(c)
	return c:IsFaceup() and c:IsCode(51638941) and c:GetUnionCount()==0
end
