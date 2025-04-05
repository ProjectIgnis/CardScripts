--古代の機械竜
--Ancient Gear Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:AddCannotBeSpecialSummoned()
	--Normal Summon this card without Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.nscon)
	c:RegisterEffect(e1)
	--Negate an opponent's activated Spell/Trap Card or effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp and re:IsSpellTrapEffect() and Duel.IsChainDisablable(ev) end)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e2)
	--"Double Snare" check
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
s.listed_names={CARD_ANCIENT_GEAR_GOLEM} --"Ancient Gear Golem"
function s.nsconfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end
function s.nscon(e)
	local tp=e:GetHandlerPlayer()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return false end
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==0 or g:FilterCount(s.nsconfilter,nil)==#g
end
function s.discostfilter(c)
	if not c:IsAbleToGraveAsCost() then return false end
	if c:IsLocation(LOCATION_DECK) then
		return c:IsCode(CARD_ANCIENT_GEAR_GOLEM)
	else
		return c:IsRace(RACE_MACHINE) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
	end
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.discostfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.discostfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end