--おジャマジック
--Ojamagic
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 each of "Ojama Green", "Ojama Yellow", and "Ojama Black" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND|LOCATION_ONFIELD) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_names={12482652,42941100,79335209} --"Ojama Green", "Ojama Yellow", "Ojama Black"
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsCode(12482652,42941100,79335209) and c:IsAbleToHand()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,12482652)
		and sg:IsExists(Card.IsCode,1,nil,42941100)
		and sg:IsExists(Card.IsCode,1,nil,79335209)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #sg<3 then return end
	local g=aux.SelectUnselectGroup(sg,e,tp,3,3,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end