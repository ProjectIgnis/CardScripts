--夢魔鏡の使徒－ネイロイ
--Neiroy, the Dream Mirror Disciple
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Return Spell/Trap to the hand + Draw and Shuffle
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.cond2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DREAM_MIRROR}
s.listed_names={CARD_DREAM_MIRROR_JOY,CARD_DREAM_MIRROR_TERROR}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_DREAM_MIRROR),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if not c:IsAttribute(ATTRIBUTE_DARK) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(ATTRIBUTE_DARK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
function s.cond2(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return re:IsMonsterEffect() and re:GetHandler():IsSetCard(SET_DREAM_MIRROR)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_SZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.ffilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsAbleToHand()
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,CARD_DREAM_MIRROR_JOY)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
	if Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,CARD_DREAM_MIRROR_TERROR) and Duel.IsPlayerCanDraw(tp,1) then
		local ct=Duel.Draw(tp,1,REASON_EFFECT)
		if ct~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local tdg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
			Duel.BreakEffect()
			Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end