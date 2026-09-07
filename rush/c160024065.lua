--Ｅ・ＨＥＲＯ エッジマン
--Elemental HERO Bladedge
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Gains 1000 ATK during the controller's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
function s.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandler():GetControler() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,63035430),e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end