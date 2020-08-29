--ドラグニティ・ヴォイド
--Dragunity Purgatory
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCode(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x29}
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x29)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return Duel.IsChainNegatable(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,re:GetHandler():GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,re:GetHandler():GetPreviousLocation())
	end
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsLevel(10)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		if not og:GetFirst():IsLocation(LOCATION_REMOVED) then return end
		local ct=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsFaceup),tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
		if ct>0 and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
			local tc=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsSetCard,0x29),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			Duel.HintSelection(Group.FromCards(tc))
			--Increase ATK
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(ct*100)
			tc:RegisterEffect(e1)
		end
	end
end
