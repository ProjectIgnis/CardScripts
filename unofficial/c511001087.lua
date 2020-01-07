--Law of Food Conservation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={511001086}
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_RULE)
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsCode(511001086)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:Filter(s.cfilter,nil,1-tp):GetCount()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_SZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,ct,nil,0x512) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:Filter(s.cfilter,nil,1-tp):GetCount()
	if not Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_SZONE,0,1,nil) 
		or ct<=0 then return end
	local fc=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,ct,ct,nil,0x512)
	if #g>0 then
		Duel.HintSelection(Group.FromCards(fc))
		Duel.Overlay(fc,g)
	end
end
