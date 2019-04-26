--Unification of Gusto
function c226185780.initial_effect(c)
	--activate effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c226185780.target)
	e1:SetOperation(c226185780.operation)
	c:RegisterEffect(e1)
	--synchro summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE+0x1c0)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c226185780.sctg)
	e2:SetOperation(c226185780.scop)
	c:RegisterEffect(e2)
end
function c226185780.filter1(c)
	return c:IsSetCard(0x10) and c:IsDiscardable(REASON_EFFECT)
end
function c226185780.filter2(c)
	return c:IsFaceup() and not c:IsSetCard(0x10) and c:IsDefensePos() and c:IsCanChangePosition()   
end
function c226185780.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(c226185780.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAttackPos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(c226185780.filter1,tp,LOCATION_HAND,0,1,nil) and g1:GetCount()>0 end
	Duel.SetTargetCard(g2)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,g1:GetCount(),tp,0)
end
function c226185780.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,c226185780.filter1,1,1,REASON_EFFECT,nil)>0 then
		local g1=Duel.GetMatchingGroup(c226185780.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.ChangePosition(g1,POS_FACEUP_ATTACK)
		local g2=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		g2=g2:Filter(Card.IsRelateToEffect,nil,e)
		for tc in aux.Next(g2) do
			tc:RegisterFlagEffect(226185780,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(c226185780.discon)
		e1:SetOperation(c226185780.disop)
		Duel.RegisterEffect(e1,tp)
	end
end
function c226185780.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc,pos=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_POSITION)
	return re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and re:GetHandler():GetFlagEffect(226185780)~=0
end
function c226185780.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function c226185780.scfilter2(c,sc)
	return c:IsFaceup() and c:IsSetCard(0x10) and c:IsCanBeSynchroMaterial(sc)
end
function c226185780.scfilter(c,e,tp)
	local g=Duel.GetMatchingGroup(c226185780.scfilter2,tp,LOCATION_MZONE,0,nil,c)
	return c:IsSynchroSummonable(nil,g)
end
function c226185780.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c226185780.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c226185780.scop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c226185780.scfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		local mg=Duel.GetMatchingGroup(c226185780.scfilter2,tp,LOCATION_MZONE,0,nil,sc)
		Duel.SynchroSummon(tp,sc,nil,mg)
	end
end