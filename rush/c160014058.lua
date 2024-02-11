--ジョインテック・イグニッション
--Jointech Ignition
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Prevent a monster from destruction by battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	local ac=Duel.GetAttacker()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and ac:IsControler(1-tp) 
		and tc:IsRace(RACE_MACHINE) and tc:IsAttribute(ATTRIBUTE_EARTH)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttackTarget()
	if chk==0 then return tg:IsControler(tp) and tg:IsOnField() end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,tg,1,tp,0)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevelAbove(7)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local tc=Duel.GetAttackTarget()
	if tc and tc:IsRelateToBattle() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		tc:RegisterEffect(e1,true)
		if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			local tg=Group.CreateGroup()
			tg:AddCard(Duel.GetAttacker())
			tg=tg:AddMaximumCheck()
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end