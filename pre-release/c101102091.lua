--JP name
--Myutant Ultimus
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Fusion summon procedure
	Fusion.AddProcMixN(c,true,true,s.ffilter,3)
	--Negate the activation of card/effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
	--Add up to 3 of your banished "Myutant" cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
	--Lists "Myutant" archetype
s.listed_series={0x259}

	--3 level 8+ "Myutant" monsters
function s.ffilter(c,fc,sumtype,tp)
	return c:IsLevelAbove(8) and c:IsSetCard(0x259,fc,sumtype,tp)
end
	--Card/effect activated
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
	--Check for "Myutant" card
function s.cfilter(c,rtype)
	return c:IsSetCard(0x259) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(rtype) and c:IsAbleToRemoveAsCost()
end
	--Banish 1 "Myutant" card from hand/face-up field/GY with same card type as activated card/effect as cost
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rtype=(re:GetActiveType()&0x7)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,rtype) end
	local rg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,rtype)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
	--Activation legality
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,re:GetHandler():GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,re:GetHandler():GetPreviousLocation())
	end
end
	--Negate the activation of card/effect, and if you do, banish it
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
	--If this fusion summoned card was destroyed by opponent's card
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:GetPreviousControler()==tp)
end
	--Check for a face-up banished "Myutant" card
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x259) and c:IsAbleToHand()
end
function s.ctcheck(sg,e,tp)
	return sg:GetClassCount(Card.GetType)==#sg
end
	--Activation legality
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
	--Add up to 3 of your banished "Myutant" cards to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,s.ctcheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end