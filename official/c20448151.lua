--道化の一座『下稽古』
--Clown Crew "Rehearsal"
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Tribute 1 monster from your hand or field; add 1 "Clown Crew Biancaviso" and 1 "Clown Crew" Spell/Trap from your Deck to your hand, except "Clown Crew "Rehearsal""
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; Ritual Summon 1 "Clown Crew" Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level
	local e2=Ritual.CreateProc(c,RITPROC_GREATER,
		function(c) return c:IsSetCard(SET_CLOWN_CREW) end,
		nil,aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CLOWN_CREW}
s.listed_names={82159583,id} --"Clown Crew Biancaviso"
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,true,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,true,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.thfilter(c)
	return (c:IsCode(82159583) or (c:IsSetCard(SET_CLOWN_CREW) and c:IsSpellTrap() and not c:IsCode(id))) and c:IsAbleToHand()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,82159583) and sg:IsExists(Card.IsSpellTrap,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #sg==2 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end