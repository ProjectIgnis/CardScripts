--created & coded by Lyris, art from It's Time to Get Medieval
--剣主御注意
function c210410011.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,210410011+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c210410011.condition)
	e1:SetOperation(c210410011.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c210410011.target)
	e2:SetOperation(c210410011.operation)
	c:RegisterEffect(e2)
end
function c210410011.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return at and ((a:IsControler(tp) and a:IsSetCard(0xfb2) and aux.nzdef(a:GetBattleTarget()))
		or (at:IsControler(tp) and at:IsFaceup() and at:IsSetCard(0xfb2) and aux.nzdef(at:GetBattleTarget())))
end
function c210410011.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,at=at,a end
	if not a:IsRelateToBattle() or a:IsFacedown() or not at:IsRelateToBattle() or at:IsFacedown() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE)
	e1:SetValue(at:GetDefense())
	a:RegisterEffect(e1)
end
function c210410011.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=Duel.GetAttackTarget()
	if chk==0 then return d:IsAttackPos() and d:IsControler(tp) and d:IsCanChangePosition() and d:IsSetCard(0xfb2) end
	Duel.SetTargetCard(d)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,d,1,0,0)
end
function c210410011.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsAttackPos() then
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
