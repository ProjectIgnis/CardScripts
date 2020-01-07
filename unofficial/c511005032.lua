--Line World
--Scripted by Sahim
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Line Monster 500 atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLineMonster))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--destroyed to opp grave
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(s.reptg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function s.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(1-tp)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if eg:IsExists(s.filter,1,nil,rp) then
		local c=eg:GetFirst():GetReasonCard()
		if not c then c=re:GetHandler() end
		Duel.RaiseEvent(c, id, e, r, rp, ep, ev)
	end	
	Duel.SendtoGrave(eg,REASON_EFFECT,rp)
	return true
end
