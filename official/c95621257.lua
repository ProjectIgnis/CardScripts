--フレムベル・マジカル
--Flamvell Magician
local s,id=GetID()
function s.initial_effect(c)
	--Gain 400 ATK if you control an "Ally of Justice" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(400)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ALLY_OF_JUSTICE}
function s.atkcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ALLY_OF_JUSTICE),e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end