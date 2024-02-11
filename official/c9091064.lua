--ＶＳ 蛟龍
--Vanquish Soul Jiaolong
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CONFIRM)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.opccost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.opccost)
	e2:SetTarget(s.vstg)
	e2:SetOperation(s.vsop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VANQUISH_SOUL}
s.listed_names={id}
function s.opccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActivated() and re:GetHandler():IsSetCard(SET_VANQUISH_SOUL)
		and r&REASON_COST>0 and rp==tp
		and eg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.vscostfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsPublic()
end
function s.thfilter(c)
	return c:IsSetCard(SET_VANQUISH_SOUL) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.vstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.vscostfilter,tp,LOCATION_HAND,0,nil)
	local b1=#cg>0 and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=#cg>1 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=cg:Select(tp,op,op,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	if op==1 then
		e:SetCategory(CATEGORY_POSITION)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.vsop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Change the battle position of 1 monster on the field
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	elseif op==2 then
		--Search 1 "Vanquish Soul" card, except "Vanquish Soul Jiaolong"
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end