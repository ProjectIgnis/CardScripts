--ゴーストリック・セイレーン
--Ghostrick Siren
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Summon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(s.sumcon)
	c:RegisterEffect(e1)
	--Change itself to face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	--Mill 2 cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP)
	c:RegisterEffect(e4)
end
s.listed_series={SET_GHOSTRICK}
function s.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GHOSTRICK)
end
function s.sumcon(e)
	return not Duel.IsExistingMatchingCard(s.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD-RESET_TURN_SET|RESET_PHASE|PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetDecktopGroup(tp,2)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
end
function s.thfilter(c)
	return c:IsSetCard(SET_GHOSTRICK) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsCanTurnSet()
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,2,REASON_EFFECT)~=2 then return end
	local og=Duel.GetOperatedGroup():Match(Card.IsSetCard,nil,SET_GHOSTRICK):Match(Card.IsLocation,nil,LOCATION_GRAVE)
	if #og==0 then return end
	local g1=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local g2=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,0,nil)
	local b1=#g1>0
	local b2=#g2>0
	if not (b1 or b2) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)})
	if op==0 then return end
	Duel.BreakEffect()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g1:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sg=g2:Select(tp,1,1,nil)
		Duel.HintSelection(sg,true)
		Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
	end
end