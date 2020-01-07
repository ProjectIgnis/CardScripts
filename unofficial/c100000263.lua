--エクシーズ弁当
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.con1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(s.con2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
end
function s.filter1(c)
	return c:GetDefense()>=2000
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil) and re:GetHandler():IsType(TYPE_XYZ)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:Filter(s.filter1,nil)
	local tc=re:GetHandler()
	if tc:IsFaceup() then
		Duel.Overlay(tc,c)
	end
end
function s.filter2(c)
	return c:GetDefense()>=2000 and c:GetBattleTarget():IsType(TYPE_XYZ)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter2,1,nil)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:Filter(s.filter2,nil)
	local tc=c:GetFirst():GetBattleTarget()
	if tc:IsFaceup() then
		Duel.Overlay(tc,c)
	end
end
