--Comic Field
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.destg)
	e4:SetValue(s.desval)
	c:RegisterEffect(e4)
end
function s.dfilter(c)
	return c:IsFaceup() and c:IsOnField() and c:IsReason(REASON_BATTLE) and c:IsComicsHero()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:FilterCount(s.dfilter,nil)==1 end
	Duel.Hint(HINT_CARD,0,id)
	local g=eg:Filter(s.dfilter,nil)
	local tc=g:GetFirst()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(500)
	tc:RegisterEffect(e1)
	return true
end
function s.desval(e,c)
	return c:IsFaceup() and c:IsOnField() and c:IsReason(REASON_BATTLE) and c:IsComicsHero()
end
