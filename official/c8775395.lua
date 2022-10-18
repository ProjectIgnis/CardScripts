--災誕の呪眼
--Evil Eye Resurrection
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Send 2 cards to the GY and add 1 "Evil Eye" Equip card to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Equip 1 "Evil Eye" card to 1 "Evil Eye" Link Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.eqpcond)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqptg)
	e2:SetOperation(s.eqpop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_EVIL_EYE}
function s.thfilter(c)
    return c:IsSetCard(SET_EVIL_EYE) and c:IsSpell() and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function s.tgfilter(c)
    return c:IsSetCard(SET_EVIL_EYE) and c:IsAbleToGraveAsCost()
end
function s.rescon(sg)
    return sg:FilterCount(Card.IsMonster,nil)==1
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
    local hg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if #hg==1 then g:Sub(hg) end
    if chk==0 then return #hg>0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
    local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
    Duel.SendtoGrave(dg,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local c=e:GetHandler()
	--Lose 500 LP each time you activate a non-"Evil Eye" card or effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetOperation(s.damop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not re:GetHandler():IsSetCard(SET_EVIL_EYE) and rp==tp then
		Duel.Hint(HINT_CARD,0,id)
		Duel.SetLP(tp,Duel.GetLP(tp)-500)
	end
end
function s.lnkfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSetCard(SET_EVIL_EYE) and c:IsSummonPlayer(tp)
end
function s.eqpcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.lnkfilter,1,nil,tp)
end
function s.eqtcfilter(c,ec)
	return c:IsSetCard(SET_EVIL_EYE) and c:IsLinkMonster() and c:IsFaceup() and ec:CheckEquipTarget(c)
end
function s.eqfilter(c,tp)
	return c:IsSetCard(SET_EVIL_EYE) and c:IsSpell() and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp)
		and Duel.IsExistingMatchingCard(s.eqtcfilter,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.eqptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.eqpop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if not ec then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.eqtcfilter,tp,LOCATION_MZONE,0,1,1,nil,ec):GetFirst()
	if tc then
		Duel.Equip(tp,ec,tc)
	end
end