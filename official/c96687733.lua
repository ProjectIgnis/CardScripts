--神殿の守護神
--Defense of the Temple
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 EARTH Fusion Monster from your Extra Deck, using monsters from your hand or field
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),nil,s.fextra)
	c:RegisterEffect(e1)
	--Add 1 "Dangers of the Divine" from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_TEMPLE_OF_THE_KINGS),tp,LOCATION_ONFIELD,0,1,nil) end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_TEMPLE_OF_THE_KINGS,22082432} -- "Dangers of the Divine"
function s.filterchk(c,tp)
	return c:ListsCode(CARD_TEMPLE_OF_THE_KINGS) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.fcheck(tp,sg,fc)
	if sg:IsExists(Card.IsControler,1,nil,1-tp) then
		return sg:IsExists(s.filterchk,1,nil,tp) end
	return true
end
function s.fextra(e,tp,mg)
	if mg:IsExists(s.filterchk,1,nil,tp) then
		local eg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.thfilter(c)
	return c:IsCode(22082432) and c:IsAbleToHand()
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