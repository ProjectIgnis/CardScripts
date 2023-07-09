--八汰鏡
--Mirror of Yata
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_SPIRIT))
	--The equipped monster don't have to return to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
	e1:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e1)
	--Destruction replacement for the equipped monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e2:SetValue(s.desval)
	c:RegisterEffect(e2)
end
s.listed_card_types={TYPE_SPIRIT}
function s.desval(e,re,r,rp)
	return (r&REASON_BATTLE)~=0
end