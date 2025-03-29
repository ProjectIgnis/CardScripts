--ゴッドハンド・スマッシュ
--Kaminote Blow
local s,id=GetID()
function s.initial_effect(c)
	--Destroy the monsters that battle with your monsters this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={8508055,3810071,49814180} --Chu-Ske the Mouse Fighter, Monk Fighter, Master Monk
function s.filter(c)
	return c:IsFaceup() and c:IsCode(8508055,3810071,49814180)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Destroy
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.cfilter(c,tp)
	return c:IsCode(8508055,3810071,49814180) and c:IsControler(tp)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if not at then return end
	local g=Group.CreateGroup()
	if s.cfilter(a,tp) and at:IsLocation(LOCATION_MZONE) then g:AddCard(at) end
	if s.cfilter(at,tp) and a:IsLocation(LOCATION_MZONE) then g:AddCard(a) end
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end