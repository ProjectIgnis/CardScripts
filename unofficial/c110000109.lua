--バスターナックル・アーマー
--Buster Knuckle
local s,id=GetID()
function s.initial_effect(c)
	Armor.AddProcedure(c)
	--Gains 200 ATK for each Armor monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e) return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_ARMOR),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*200 end)
	c:RegisterEffect(e2)
	--Piercing
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
end
