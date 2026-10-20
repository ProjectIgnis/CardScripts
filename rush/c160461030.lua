--Ｅ・ＨＥＲＯ ワイルドマン (Rush)
--Elemental HERO Wildheart (Rush)
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	--This card cannot be destroyed by Trap Card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
	--Cannot be returned to the hand/Deck/Extra Deck by Trap Card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg2)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e3)
	--During your turn, if "Skyscraper" is face-up on the field, this card gains 1000 ATK.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.condition)
	e4:SetValue(1000)
	c:RegisterEffect(e4)
end
s.listed_names={63035430} --Skyscrapper
function s.indval(e,re,rp)
	return re:IsActiveType(TYPE_TRAP)
end
function s.indtg2(e,c)
	return c==e:GetHandler()
end
function s.value(e,re,rp)
	return re and re:GetHandler():IsTrap()
end
function s.condition(e)
	return Duel.IsTurnPlayer(e:GetHandlerPlayer())
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,63035430),e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end