--ブラ・クマ・ジシャン (im really proud of this pun)
--Dark Magician Bear
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(1040,3))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+1)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_MAGICIAN}
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
    if chk==0 then return #g>0 and g:FilterCount(Card.IsReleasable,nil)==#g end
    Duel.Release(g,REASON_COST)
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsCode(CARD_DARK_MAGICIAN)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,g)
		--cannot disable summon
    	local e1=Effect.CreateEffect(c)
    	e1:SetType(EFFECT_TYPE_FIELD)
    	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
    	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
    	e1:SetReset(RESET_PHASE+PHASE_END)
    	Duel.RegisterEffect(e1,tp)
    	--activate limit
    	local e2=Effect.CreateEffect(c)
    	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    	e2:SetOperation(s.cedop)
    	e2:SetReset(RESET_PHASE+PHASE_END)
    	Duel.RegisterEffect(e2,tp)
    	local e3=Effect.CreateEffect(c)
    	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    	e3:SetCode(EVENT_CHAIN_END)
    	e3:SetOperation(s.cedop2)
    	e3:SetReset(RESET_PHASE+PHASE_END)
    	Duel.RegisterEffect(e3,tp)
	end
end
function s.cedop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SetChainLimitTillChainEnd(s.chlimit)
end
function s.cedop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) then
        Duel.SetChainLimitTillChainEnd(s.chlimit)
    end
end
function s.chlimit(re,rp,tp)
    return rp==tp
end