--Japanese name
--Prey of the Jirai Gumo
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add 1 "Sanga of the Thunder", "Kazejin", or "Suijin" to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names=CARDS_SANGA_KAZEJIN_SUIJIN
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=c:GetColumnZone(LOCATION_MZONE)&ZONES_MMZ
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and zone>0 and not Duel.IsExistingMatchingCard(Card.IsZone,tp,LOCATION_MZONE,0,1,nil,zone,tp)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_NORMAL,2100,100,5,RACE_INSECT,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local zone=c:GetColumnZone(LOCATION_MZONE)&ZONES_MMZ
	if not (c:IsRelateToEffect(e) and zone>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_NORMAL,2100,100,5,RACE_INSECT,ATTRIBUTE_EARTH)) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP,zone)
	c:AddMonsterAttributeComplete()
	Duel.SpecialSummonComplete()
	local g=c:GetColumnGroup():Match(Card.IsControler,nil,1-tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,1,nil)
		if #dg>0 then
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
function s.thfilter(c)
	return c:IsCode(CARDS_SANGA_KAZEJIN_SUIJIN) and c:IsAbleToHand() and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end