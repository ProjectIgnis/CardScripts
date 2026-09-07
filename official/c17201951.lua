--フルスピード・ウォリアー
--Full-Speed Warrior
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Junk Synchron" or 1 Spell/Trap that mentions "Junk Warrior" from your Deck to your hand
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.thtg)
	e1a:SetOperation(s.thop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--Monsters you control that mention "Junk Warrior", and Synchro Monsters you control with "Warrior" in their original names, gain 900 ATK during your Battle Phase only
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(function(e) return Duel.IsBattlePhase() and Duel.IsTurnPlayer(e:GetHandlerPlayer()) end)
	e2:SetTarget(function(e,c) return c:ListsCode(CARD_JUNK_WARRIOR) or (c:IsType(TYPE_SYNCHRO) and c:IsOriginalSetCard(SET_WARRIOR)) end)
	e2:SetValue(900)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_JUNK_SYNCHRON,CARD_JUNK_WARRIOR}
s.listed_series={SET_WARRIOR}
function s.thfilter(c)
	return (c:IsCode(CARD_JUNK_SYNCHRON) or (c:IsSpellTrap() and c:ListsCode(CARD_JUNK_WARRIOR))) and c:IsAbleToHand()
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