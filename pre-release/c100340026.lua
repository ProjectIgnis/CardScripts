--緊急発進
--The Calm After the Ice Barrier’s Storm
--Logical Nonsense

local s,id=GetID()
function s.initial_effect(c)
	--Special summon level 4 or lower "Ice Barrier" monsters from deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add 1 of your "Ice Barrier" monsters, that is banished or in GY, to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
	--Lists "Ice Barrier" archetype
s.listed_series={0x2f}

	--Check for level 4 or lower "Ice Barrier" monsters
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4)
end
	--Tribute up to the number of cards in s.spfilter
function s.check(ct)
	return function(sg,tp)
		--local codes=sg:GetClass(Card.GetCode)
		return aux.ChkfMMZ(#sg)(sg,nil,tp) and ct:GetClassCount(Card.GetCode)>=#sg
	end
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local ct=#cg
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return false end
		return ct>0 and Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,99,false,s.check(cg),nil,0x2f)
	end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,ct,false,s.check(cg),nil,0x2f)
	Duel.Release(g,REASON_COST)
	e:SetLabel(#g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#g,tp,LOCATION_DECK)
end
	--Special summon level 4 or lower "Ice Barrier" monsters from deck
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=e:GetLabel()
	if ft<ct then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g<ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
	--Check for an "Ice Barrier" monster
function s.thfilter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
	--Activation legality
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
	--Add 1 of your "Ice Barrier" monsters, that is banished or in GY
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
