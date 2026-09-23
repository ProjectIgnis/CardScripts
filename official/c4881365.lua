--ワイバーンの竜騎士
--Alligator's Sword Dragon Knight
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Can attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
	--If this card is in your hand: You can reveal 1 other card in your hand that mentions "Dark Time Wizard"; Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(Cost.Reveal(function(c) return c:ListsCode(CARD_DARK_TIME_WIZARD) end,true))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--If this card is Normal or Special Summoned: You can add up to 2 Spells/Traps with different names from each other that mention "Dark Time Wizard" from your Deck to your hand, then discard 1 card
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_SUMMON_SUCCESS)
	e3a:SetCountLimit(1,{id,1})
	e3a:SetTarget(s.thtg)
	e3a:SetOperation(s.thop)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3b)
end
s.listed_names={CARD_DARK_TIME_WIZARD}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thfilter(c)
	return c:IsSpellTrap() and c:ListsCode(CARD_DARK_TIME_WIZARD) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT|REASON_DISCARD,nil,REASON_EFFECT)
	end
end