--カイザー・シーホース (Deck Master)
--Kaiser Sea Horse (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_FIELD)
	dme1:SetCode(EFFECT_DECREASE_TRIBUTE)
	dme1:SetTargetRange(LOCATION_HAND,0)
	dme1:SetCondition(function(e) return Duel.IsDeckMaster(e:GetOwnerPlayer(),id) end)
	dme1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
	dme1:SetValue(0x1)
	local dme2=dme1:Clone()
	dme2:SetCode(EFFECT_DECREASE_TRIBUTE_SET)
	DeckMaster.RegisterAbilities(c,dme1,dme2)
	--double tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
	c:RegisterEffect(e1)
end