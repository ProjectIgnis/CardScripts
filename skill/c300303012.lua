--I'm Just Gonna Attack!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)
	end
	e:SetLabel(1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	Duel.RegisterEffect(e1,tp)
	--Trap negate/reset
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1)
	e2:SetCondition(s.trapcon)
	e2:SetTarget(s.traptg)
	e2:SetOperation(s.trapop)
	Duel.RegisterEffect(e2,tp)
end
function s.atkfilter(c)
	return c:IsMonster() and c:IsFaceup()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp) and c:GetFlagEffect(id)==0
		and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_PHASE|PHASE_END,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(100)
		e1:SetReset(RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
function s.trapcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and Duel.IsTurnPlayer(tp)
		and rp==1-tp and re:IsTrapEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsChainDisablable(ev)
end
function s.traptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.trapop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) and rc:IsSSetable(true) then
		rc:CancelToGrave()
		Duel.ChangePosition(rc,POS_FACEDOWN)
	end
end