--クロスカウンター
--Cross Counter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	return bc and bc:IsPosition(POS_FACEUP_DEFENSE) and bc:IsControler(tp) and Duel.GetAttacker():GetAttack()<bc:GetDefense()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=Duel.GetAttackTarget()
	if bc:IsFaceup() and bc:IsRelateToBattle() then
		--Any battle damage your monster inflicts on your opponent during that battle is doubled
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetCondition(function(e) return Duel.GetAttackTarget()==e:GetHandler() end)
		e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		bc:RegisterEffect(e1)
	end
	local ac=Duel.GetAttacker()
	--Destroy the attacking monster at the end of the Damage Step
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetOperation(function() if ac:IsRelateToBattle() then Duel.Destroy(ac,REASON_EFFECT) end end)
	e2:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end
