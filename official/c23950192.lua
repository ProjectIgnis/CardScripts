--氷結界の術者
--Cryomancer of the Ice Barrier
local s,id=GetID()
function s.initial_effect(c)
	--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tg)
	e2:SetCondition(s.con)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ICE_BARRIER}
function s.con(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ICE_BARRIER),e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.tg(e,c)
	return c:GetLevel()>=4
end