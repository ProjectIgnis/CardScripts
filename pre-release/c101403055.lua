--竜の骸歌
--Reindsurm Conquest
--scripted by pyrQ
local s,id=GetID()function s.initial_effect(c)
	--This card can be used to Ritual Summon any number of Insect Ritual Monsters. You must also shuffle Insect and/or Dragon monsters from the GY(s) into the Deck whose total Levels equal or exceed the total Levels of the Ritual Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If this card is in your GY: You can send 1 Insect monster from your hand or face-up field to the GY; add this card to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.matfilter(c)
	return c:IsRace(RACE_INSECT|RACE_DRAGON) and c:HasLevel() and c:IsAbleToDeck()
end
function s.spfilter(c,e,tp,max_lv)
	return c:IsRace(RACE_INSECT) and c:IsRitualMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		and c:IsLevelBelow(max_lv)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		return #mg>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg:GetSum(Card.GetLevel))
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_EITHER,LOCATION_GRAVE)
end
function s.rescon(max_lv)
	return function(sg,e,tp,mg)
		local sg_lvsum=sg:GetSum(Card.GetLevel)
		return sg_lvsum<=max_lv,sg_lvsum>max_lv
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local max_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if max_count<=0 then return end
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.matfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #mg==0 then return end
	local max_lv=mg:GetSum(Card.GetLevel)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp,max_lv)
	if #sg==0 then return end
	max_count=math.min(max_count,#sg)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then max_count=1 end
	local rescon=s.rescon(max_lv)
	local summon_group=aux.SelectUnselectGroup(sg,e,tp,1,max_count,rescon,1,tp,HINTMSG_SPSUMMON,rescon)
	if #summon_group==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local final_mats=mg:SelectWithSumGreater(tp,Card.GetLevel,summon_group:GetSum(Card.GetLevel))
	if #final_mats==0 then return end
	for sc in summon_group:Iter() do
		sc:SetMaterial(final_mats)
	end
	Duel.HintSelection(final_mats)
	Duel.SendtoDeck(final_mats,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_RITUAL|REASON_MATERIAL)
	Duel.BreakEffect()
	for sc in summon_group:Iter() do
		Duel.SpecialSummonStep(sc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		sc:CompleteProcedure()
	end
	Duel.SpecialSummonComplete()
end
function s.thcostfilter(c)
	return c:IsRace(RACE_INSECT) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToGraveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end