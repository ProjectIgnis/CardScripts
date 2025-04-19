--お注射天使リリー
--Injection Fairy Lily (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--ATK increase+double attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,160019053) then return Duel.CheckLPCost(tp,100) end
		return Duel.CheckLPCost(tp,2000)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,3000)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	local lpcost=2000
	if Duel.IsPlayerAffectedByEffect(tp,160019053) and (not Duel.CheckLPCost(tp,2000) or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		lpcost=100
	end
	Duel.PayLPCost(tp,lpcost)
	--Effect
	--Increase ATK by 3000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(3000)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end