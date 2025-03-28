--氷結界の破術師
--Warlock of the Ice Barrier
local s,id=GetID()
function s.initial_effect(c)
	--cannot activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetCondition(s.con)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SSET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.con)
	e3:SetOperation(s.aclimset)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ICE_BARRIER}
function s.con(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ICE_BARRIER),e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsSpellEffect() then return false end
	local c=re:GetHandler()
	return not c:IsLocation(LOCATION_SZONE) or c:GetFlagEffect(id)>0
end
function s.aclimset(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN,0,1)
	end
end