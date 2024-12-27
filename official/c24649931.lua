--変幻
--Materialization
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if not (chkc:IsLocation(LOCATION_STZONE) and chkc:IsOriginalType(TYPE_MONSTER) and chkc:IsFaceup()) then return false end
		local label=e:GetLabel()
		if label==1 then
			local owner=chkc:GetOwner()
			return Duel.GetLocationCount(owner,LOCATION_MZONE)>0
				and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,owner)
		elseif label==2 then
			return chkc:IsAbleToHand()
		elseif label==3 then
			return true
		end
	end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsOriginalType,TYPE_MONSTER),tp,LOCATION_STZONE,LOCATION_STZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsOriginalType,TYPE_MONSTER),tp,LOCATION_STZONE,LOCATION_STZONE,1,1,nil):GetFirst()
	local owner=tc:GetOwner()
	local b1=Duel.GetLocationCount(owner,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,owner)
	local b2=tc:IsAbleToHand()
	local b3=true
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_MZONE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local op=e:GetLabel()
	if op==1 then
		--Special Summon it to its owner's field
		Duel.SpecialSummon(tc,0,tp,tc:GetOwner(),false,false,POS_FACEUP)
	elseif op==2 then
		--Return it to the hand
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	elseif op==3 then
		--Destroy it, then you can destroy 1 monster on the field with an equal or lower Level
		if Duel.Destroy(tc,REASON_EFFECT)==0 or not tc:HasLevel() then return end
		local lv=tc:GetLevel()
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevelBelow,lv),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsLevelBelow,lv),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			if #g==0 then return end
			Duel.HintSelection(g,true)
			Duel.BreakEffect()
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end