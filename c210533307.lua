--Puella Magi Incubator - Kyubey
function c210533307.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c210533307.matfilter,2,2,nil,nil)
	--add a card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c210533307.tht)
	e1:SetOperation(c210533307.tho)
	e1:SetCountLimit(1,210533306)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c210533307.spt1)
	e2:SetOperation(c210533307.spo1)
	e2:SetCountLimit(1,210533307)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c210533307.spcon)
	e3:SetTarget(c210533307.spt2)
	e3:SetOperation(c210533307.spo2)
	e3:SetCountLimit(1,210533308)
	c:RegisterEffect(e3)
end
function c210533307.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0xf72,scard,sumtype,tp)
end
function c210533307.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xf74)
end
function c210533307.tht(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210533307.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210533307.tho(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210533307.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end
function c210533307.spf(c,e,tp,sg)
	return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,72,tp,false,false) and (not sg or not sg:IsExists(Card.IsCode,1,c,c:GetCode()))
end
function c210533307.spt1(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_HAND end
		if Duel.GetLocationCountFromEx(tp)>0 then loc=loc|LOCATION_EXTRA end
		return loc>0 and Duel.IsExistingMatchingCard(c210533307.spf,tp,loc,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
function c210533307.spo1(e,tp,eg,ep,ev,re,r,rp)
	--zone check
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 and Duel.GetLocationCountFromEx(tp)==0 then return end
	--BESP check
	local besp_check=Duel.IsPlayerAffectedByEffect(tp,59822133)
	--Summon Gate check
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	--number of monster summoned from extra
	local st=0
	--special summoned monster
	local sg=Group.CreateGroup()
	while true do
		--check from where you can special summon and exit if there no place
		local loc=0
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_HAND end
		if Duel.GetLocationCountFromEx(tp)>0 then loc=loc|LOCATION_EXTRA end
		if loc==0 then break end
		--check if you can stop alredy
		local min=(#sg>0) and 0 or 1
		--select a card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,c210533307.spf,tp,loc,0,min,1,nil,e,tp,sg):GetFirst()
		--if no card then exit
		if not tc then break end
		--add the card to special summoned monster group
		sg=sg+tc
		--counts number of monster special summoned from extra
		if tc:IsLocation(LOCATION_EXTRA) then
			st=st+1
		end
		--special summon
		Duel.SpecialSummonStep(tc,72,tp,tp,false,false,POS_FACEUP)
		--BESP check
		if besp_check and #sg>=1 then break end
		--Summon Gate Check
		if ect and st>=ect then break end
	end
	local sc=Duel.SpecialSummonComplete()
end
function c210533307.spconf(c)
	return c:IsFaceup() and c:IsSetCard(0xf72)
end
function c210533307.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210533307.spconf,tp,LOCATION_PZONE,0,1,nil)
end
function c210533307.spt2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_GRAVE)
end
function c210533307.spo2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
