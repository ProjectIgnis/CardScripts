--ボスオンパレード
--Boss on Parade
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: Add 1 "B.E.S." monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Destroy 1 monster in your hand or field, and if you do, Special Summon 1 LIGHT Machine monster with 1200 ATK and 1000 or less DEF from your Deck to either field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Place 1 "Boss Rush" from your Deck or GY face-up on your field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
end
s.listed_names={66947414} --"Boss Rush"
s.listed_series={SET_BES}
function s.thfilter(c)
	return c:IsSetCard(SET_BES) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.desfilter(c,e,tp)
	return c:IsMonster() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,Duel.GetMZoneCount(tp,c)>0,Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
end
function s.spfilter(c,e,tp,mmz_chk,opp_mmz_chk)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAttack(1200) and c:IsDefenseBelow(1000)
		and ((mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		or (opp_mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,e,tp)
	if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)>0 then
		local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local opp_mmz_chk=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mmz_chk,opp_mmz_chk):GetFirst()
		if not sc then return end
		local b1=mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local b2=opp_mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
		if not (b1 or b2) then return end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
		local to_player=op==1 and tp or 1-tp
		Duel.SpecialSummon(sc,0,tp,to_player,false,false,POS_FACEUP)
	end
end
function s.plfilter(c,tp)
	return c:IsCode(66947414) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if sc then
		Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end