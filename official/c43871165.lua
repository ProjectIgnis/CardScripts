--獄神影機－ゼグレド
--Power Patron Shadow Machine Zegredo
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--During your Main Phase: You can destroy both this card and 1 "Power Patron" or "DoomZ" monster in your hand or face-up field, then you can destroy 1 card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.pdestg)
	e1:SetOperation(s.pdesop)
	c:RegisterEffect(e1)
	--You can banish (face-down) the top 3 cards of your Deck; destroy this card, and if you do, Special Summon 1 "Jupiter the Power Patron of Destruction" from your Extra Deck (this is treated as an Xyz Summon), then you can attach 1 card from your hand to it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.mdescost)
	e2:SetTarget(s.mdestg)
	e2:SetOperation(s.mdesop)
	c:RegisterEffect(e2)
	--If this card is added to your Extra Deck face-up: You can add 1 "Power Patron" or "DoomZ" Spell/Trap from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_names={68231287} --"Jupiter the Power Patron of Destruction"
s.listed_series={SET_POWER_PATRON,SET_DOOMZ}
function s.pdesfilter(c)
	return c:IsSetCard({SET_POWER_PATRON,SET_DOOMZ}) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsMonster()
end
function s.pdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pdesfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),2,tp,LOCATION_PZONE|LOCATION_MZONE|LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.pdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,s.pdesfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,1,1,nil)
	if #g1==0 then return end
	if g1:GetFirst():IsOnField() then Duel.HintSelection(g1) end
	if Duel.Destroy(g1+c,REASON_EFFECT)~=2 then return end
	local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #dg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=dg:Select(tp,1,1,nil)
	if #g2>0 then
		Duel.HintSelection(g2)
		Duel.BreakEffect()
		Duel.Destroy(g2,REASON_EFFECT)
	end
end
function s.mdescost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:IsExists(Card.IsAbleToRemoveAsCost,3,nil,POS_FACEDOWN) end
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.jupiterspfilter(c,e,tp,hc)
	return c:IsCode(68231287) and Duel.GetLocationCountFromEx(tp,tp,hc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.mdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.jupiterspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.mdesop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xc=Duel.SelectMatchingCard(tp,s.jupiterspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if not xc then return end
	xc:SetMaterial(nil)
	if Duel.SpecialSummon(xc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)==0 then return end
	xc:CompleteProcedure()
	local g=Duel.GetMatchingGroup(Card.IsCanBeXyzMaterial,tp,LOCATION_HAND,0,nil,xc,tp,REASON_EFFECT)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,4)) then return end
	local attg=g:Select(tp,1,1,nil)
	if #attg>0 then
		Duel.BreakEffect()
		Duel.Overlay(xc,attg)
	end
end
function s.spfilter(c,e,tp)
	if not c:IsSetCard({SET_POWER_PATRON,SET_ARTMAGE}) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	else
		return c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0
	end
end
function s.spcon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thcon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
function s.thfilter(c)
	return c:IsSetCard({SET_POWER_PATRON,SET_DOOMZ}) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
