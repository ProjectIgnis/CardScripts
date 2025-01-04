--転生炎獣の炎軍
--Salamangreat Charge
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle 2 FIRE monsters into the Deck and Special Summon another one OR destroy 1 card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter1(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.filter2(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsType(TYPE_RITUAL|TYPE_EXTRA) and c:GetAttack()~=c:GetBaseAttack()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.spcheck,1,nil,sg,e,tp)
end
function s.spcheck(c,sg,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and sg:FilterCount(Card.IsAbleToDeck,c)==2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
	local b1=#g>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
	local b2=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	if chkc then return e:GetLabel()==2 and chkc:IsOnField() and chck~=c end
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON)
		local rg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_TARGET)
		Duel.SetTargetCard(rg)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,rg,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,rg,2,tp,0)
	else
		e:SetCategory(CATEGORY_DESTROY)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Shuffle 2 FIRE monsters and Special Summon another
		local g=Duel.GetTargetCards(e)
		if #g<3 then return end
		local tdg=aux.SelectUnselectGroup(g,e,tp,2,2,s.selectcond(g),1,tp,HINTMSG_TODECK)
		g:RemoveCard(tdg)
		if Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
		local tc=g:GetFirst()
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local c=e:GetHandler()
			--Negate its effects
			tc:NegateEffects(c,RESET_PHASE|PHASE_END)
			--Cannot attack
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3206)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
	else
		--Destroy 1 card on the field
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
function s.selectcond(resg)
	return function (sg,e,tp,mg)
		return sg:IsExists(Card.IsAbleToDeck,2,nil) and resg:IsExists(Card.IsCanBeSpecialSummoned,1,sg,e,0,tp,false,false)
	end
end