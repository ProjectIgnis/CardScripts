--魔法族の里
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--adjust
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.adjustop)
	c:RegisterEffect(e2)
	--cannot activate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,1)
	e3:SetLabel(0)
	e3:SetValue(s.actlimit)
	c:RegisterEffect(e3)
	e2:SetLabelObject(e3)
end
function s.actlimit(e,te,tp)
	if not te:IsHasType(EFFECT_TYPE_ACTIVATE) or not te:IsActiveType(TYPE_SPELL) then return false end
	if tp==e:GetHandlerPlayer() then return e:GetLabel()==1
	else return e:GetLabel()==2 end
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_SPELLCASTER),tp,0,LOCATION_MZONE,1,nil)
	local te=e:GetLabelObject()
	if not b1 then te:SetLabel(1)
	elseif b1 and not b2 then te:SetLabel(2)
	else te:SetLabel(0) end
end
