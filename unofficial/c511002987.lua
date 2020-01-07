--Earthbound Prisoner Ground Keeper
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.indtg)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsEarthbound()
end
function s.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.filter,1,nil,tp) end
	return true
end
function s.indval(e,c)
	return s.filter(c,e:GetHandlerPlayer())
end
