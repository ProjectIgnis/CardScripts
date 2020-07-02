--精霊術の使い手
--Masters of the Spiritual Arts
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Take card from the deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xbf,0xc0,0x10c0}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.filter2(c,e,tp,mft,sft,code)
	return  not c:IsCode(code) and 
		((mft>0 and c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xbf) or c:IsSetCard(0x10c0)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
		or (sft>0 and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xc0) and c:IsSSetable()))
end
function s.filter(c,e,tp,mft,sft)
	return  c:IsAbleToHand() and
	((c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xbf) or c:IsSetCard(0x10c0))) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xc0)))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,c,e,tp,mft,sft,c:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then sft=sft-1 end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,mft,sft) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,mft,sft) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local c1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mft,sft)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local c2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,mft,sft,c1:GetFirst():GetCode())
	if c1 and c2 then
		Duel.SendtoHand(c1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c1)
		if c2:GetFirst():IsType(TYPE_MONSTER) then
			Duel.SpecialSummon(c2,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		else
			Duel.SSet(tp,c2)
		end
	end
end