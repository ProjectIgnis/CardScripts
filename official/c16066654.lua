--JP name
--R.B. Operation Test
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: You can target 1 Level 3 or higher "R.B." monster in your GY; Special Summon it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Gain LP equal to the combined original ATK of the targeted "R.B." monsters, and if you do, return them to the hand/Extra Deck, then you can Special Summon 1 "R.B." monster from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.recthsptg)
	e2:SetOperation(s.recthspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RB}
function s.spfromgyfilter(c,e,tp)
	return c:IsLevelAbove(3) and c:IsSetCard(SET_RB) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfromgyfilter(chkc,e,tp) end
	if chk==0 then return true end
	if Duel.IsExistingTarget(s.spfromgyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfromgyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.recthfilter(c)
	return c:IsSetCard(SET_RB) and c:IsFaceup() and (c:IsAbleToHand() or c:IsAbleToExtra())
end
function s.recthsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.recthfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.recthfilter,tp,LOCATION_MZONE,0,1,nil) end
	local ct=Duel.GetTargetCount(s.recthfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.recthfilter,tp,LOCATION_MZONE,0,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetSum(Card.GetBaseAttack))
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spfromhandfilter(c,e,tp)
	return c:IsSetCard(SET_RB) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.recthspop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
	if #tg==0 then return end
	local sum=tg:GetSum(Card.GetBaseAttack)
	if Duel.Recover(tp,sum,REASON_EFFECT)>0 and Duel.SendtoHand(tg,nil,REASON_EFFECT)>0 and Duel.GetMZoneCount(tp)>0
		and tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND|LOCATION_EXTRA)>0
		and Duel.IsExistingMatchingCard(s.spfromhandfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
		Duel.ShuffleHand(tp)
		if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfromhandfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
