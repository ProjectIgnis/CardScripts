--堕天使エデ・アーラエ
--Darklord Edeh Arae
local s,id=GetID()
function s.initial_effect(c)
	--spsum success
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.gete)
	c:RegisterEffect(e1)
end
function s.gete(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetPreviousLocation()~=LOCATION_GRAVE then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
	e:GetHandler():RegisterEffect(e1)
end