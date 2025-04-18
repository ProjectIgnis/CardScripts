--氷結界の守護陣
--Defender of the Ice Barrier
local s,id=GetID()
function s.initial_effect(c)
	--cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.tg)
	e1:SetCondition(s.con)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ICE_BARRIER}
function s.con(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ICE_BARRIER),e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.tg(e,c)
	return c:GetAttack()>=e:GetHandler():GetDefense()
end