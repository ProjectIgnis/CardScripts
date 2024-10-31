--原質の炉心溶融
--Materiactor Meltdown
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Excavate the top 6 cards of your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.exctg)
	e1:SetOperation(s.excop)
	c:RegisterEffect(e1)
	--Attach the top card of your Deck to 1 "Materiactor" Xyz Monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp and re:IsMonsterEffect() and re:IsActiveType(TYPE_XYZ) end)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MATERIACTOR}
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=6 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_OVERLAY)
end
function s.deckthfilter(c)
	return c:IsSetCard(SET_MATERIACTOR) and c:IsAbleToHand()
end
function s.xyzfilter(c)
	return c:IsRank(3) and c:IsType(TYPE_XYZ) and c:IsFaceup() and c:GetOverlayGroup():IsExists(Card.IsAbleToHand,1,nil)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<6 then return end
	local ct=6
	Duel.ConfirmDecktop(tp,6)
	local g=Duel.GetDecktopGroup(tp,6)
	if g:IsExists(s.deckthfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:FilterSelect(tp,s.deckthfilter,1,1,nil)
		if #sg>0 then
			Duel.DisableShuffleCheck()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			Duel.ShuffleHand(tp)
			ct=ct-1
		end
	end
	Duel.SortDecktop(tp,tp,ct)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if #xyzg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local og=Duel.GetOverlayGroup(tp,1,0,xyzg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=og:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			Duel.ShuffleHand(tp)
		end
	end
end
function s.attachfilter(c)
	return c:IsSetCard(SET_MATERIACTOR) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
	local xyzc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if xyzc then
		Duel.HintSelection(xyzc)
		local g=Duel.GetDecktopGroup(tp,1)
		Duel.DisableShuffleCheck()
		Duel.Overlay(xyzc,g)
	end
end