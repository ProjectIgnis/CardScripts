--月の女戦士
--Penumbral Soldier Lady (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.condtion)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
end
function s.condtion(e)
	return Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_LIGHT),e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end