--ダイナレスラー・マーシャルアンキロ
--Dinowrestler Martial Ankylo
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--atk change
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x11a}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local b=a:GetBattleTarget()
	if not b then return false end
	if a:IsControler(1-tp) then a,b=b,a end
	if a and b then
		local dif=b:GetAttack()-a:GetAttack()
		return a:GetControler()~=b:GetControler() and a~=e:GetHandler()
		and a:IsSetCard(0x11a) and a:IsRelateToBattle()
		and Duel.GetAttackTarget()~=nil and dif>=0
	else return false end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local b=a:GetBattleTarget()
	if a:IsControler(1-tp) then a,b=b,a end
	if a:IsRelateToBattle() and not a:IsImmuneToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
		if b:IsRelateToBattle() and not b:IsImmuneToEffect(e) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EVENT_BATTLED)
			e2:SetLabelObject(b)
			e2:SetRange(LOCATION_MZONE)
			e2:SetOperation(s.atkop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
			b:RegisterEffect(e2)
		end
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local b=e:GetLabelObject()
	if b:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(b:GetAttack()/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		b:RegisterEffect(e1)
	end
end