--立炎星－トウケイ
--Brotherhood of the Fire Fist - Rooster
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.Replaceable(s.setcost,s.extracon))
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FIRE_FIST,SET_FIRE_FORMATION}
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(SET_FIRE_FIST) and re:GetHandler():IsMonster()
end
function s.thfilter(c)
	return c:IsSetCard(SET_FIRE_FIST) and c:IsMonster() and c:IsAbleToHand()
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
function s.setfilter(c,field)
	return c:IsSetCard(SET_FIRE_FORMATION) and c:IsSpellTrap() and c:IsSSetable(not field)
end
function s.setcostfilter(c,tp,has_zone)
	return c:IsFaceup() and c:IsSetCard(SET_FIRE_FORMATION) and c:IsSpellTrap() and c:IsAbleToGraveAsCost()
		--needs S/T equivalent of Duel.GetMZoneCount for proper handling
		and (has_zone or c:IsLocation(LOCATION_STZONE) or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,true))
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local has_zone=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.setcostfilter,tp,LOCATION_ONFIELD,0,1,nil,tp,has_zone) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.setcostfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp,has_zone)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.extracon(base,e,tp)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,true)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,Duel.GetLocationCount(tp,LOCATION_SZONE)==0)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
