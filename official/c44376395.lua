--
--ASHLAN U1000
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 monsters with different Types and Attributes
	Link.AddProcedure(c,nil,2,nil,s.spcheck)
	--If a Ritual Monster this card points to attacks a Defense Position monster, inflict piercing battle damage to your opponent
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsRitualMonster() and e:GetHandler():GetLinkedGroup():IsContains(c) end)
	c:RegisterEffect(e1)
	--Add 1 Ritual Monster with a different Type and Attribute than the revealed monster from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Return 1 face-up card your opponent controls to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.rthcon)
	e3:SetTarget(s.rthtg)
	e3:SetOperation(s.rthop)
	c:RegisterEffect(e3)
end
function s.spcheck(g,lc,sumtype,tp)
	return g:CheckDifferentPropertyBinary(Card.GetRace,lc,sumtype,tp) and g:CheckDifferentPropertyBinary(Card.GetAttribute,lc,sumtype,tp)
end
function s.thcostfilter(c,tp)
	return c:IsRitualMonster() and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetRace(),c:GetAttribute())
end
function s.thfilter(c,race,attribute)
	return c:IsRitualMonster() and c:IsRaceExcept(race) and c:IsAttributeExcept(attribute) and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)
	e:SetLabelObject(rc)
	rc:CreateEffectRelation(e)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject()
	if not rc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,rc:GetRace(),rc:GetAttribute())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.rthconfilter(c,tp)
	return c:IsRitualSummoned() and c:IsSummonPlayer(tp)
end
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.rthconfilter,1,nil,tp)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end