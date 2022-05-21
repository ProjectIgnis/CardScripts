-- 絶望と希望の逆転
-- Exchange of the Heart
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Send all monsters to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_EXCHANGE_SPIRIT}
function s.tgconfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_FAIRY)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.tgconfilter,tp,LOCATION_MZONE,0,3,nil)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #tg<1 or Duel.SendtoGrave(tg,REASON_EFFECT)<1 or #tg:Match(Card.IsLocation,nil,LOCATION_GRAVE)<1 then return end
	local p=Duel.GetTurnPlayer()
	local ct=tg:FilterCount(Card.IsControler,nil,1-p)
	local g1=s.spselect(p,e,ct)
	local spcount=0
	if g1 and #g1>0 then
		Duel.BreakEffect()
		spcount=spcount+Duel.SpecialSummon(g1,0,p,p,false,false,POS_FACEUP)
	end
	local g2=s.spselect(1-p,e,#tg-ct)
	if g2 and #g2>0 then
		if spcount==0 then Duel.BreakEffect() end
		spcount=spcount+Duel.SpecialSummon(g2,0,1-p,1-p,false,false,POS_FACEUP)
	end
	if spcount>0
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_EXCHANGE_SPIRIT)
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g<1 then return end
		Duel.BreakEffect()
		if Duel.SSet(tp,g)>0 then
			-- Set Trap can be activated this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
		end
	end
end
function s.spselect(p,e,ct)
	if ct<1 then return end
	local ft=math.min(ct,Duel.GetLocationCount(p,LOCATION_MZONE))
	if ft>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),p,0,LOCATION_GRAVE,1,nil,e,0,p,false,false)
		and Duel.SelectYesNo(p,aux.Stringid(id,1)) then
		if Duel.IsPlayerAffectedByEffect(p,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
		return Duel.SelectMatchingCard(p,aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),p,0,LOCATION_GRAVE,1,ct,nil,e,0,p,false,false)
	end
end