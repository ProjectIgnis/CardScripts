--ノヴァ・ポータル
--Nova Portal
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,2,nil,id) end
	local dg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_PZONE,0,nil,id)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,1-tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,2,tp,LOCATION_PZONE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local dg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_PZONE,0,nil,id)
	if Duel.Destroy(#dg==2 and dg or dg:Select(tp,2,2,nil),REASON_EFFECT)==2 and Duel.NegateActivation(ev) then
		local turnp=Duel.GetTurnPlayer()
		Duel.SkipPhase(turnp,PHASE_DRAW,RESET_PHASE+PHASE_END,1)
		Duel.SkipPhase(turnp,PHASE_STANDBY,RESET_PHASE+PHASE_END,1)
		Duel.SkipPhase(turnp,PHASE_MAIN1,RESET_PHASE+PHASE_END,1)
		Duel.SkipPhase(turnp,PHASE_BATTLE,RESET_PHASE+PHASE_END,1,1)
		Duel.SkipPhase(turnp,PHASE_MAIN2,RESET_PHASE+PHASE_END,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BP)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,turnp)
	end
end