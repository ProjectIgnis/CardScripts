--アームド・ドラゴン・サンダー ＬＶ５
--Armed Dragon Thunder LV5
--Scripted by AlphaKretin
Duel.LoadCardScript("c46384672.lua")
local s,id=GetID()
function s.initial_effect(c)
	--This card's name becomes "Armed Dragon LV5" while on the field or in the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(46384672)
	c:RegisterEffect(e1)
	--Special Summon 1 Level 7 or lower "Armed Dragon" monster from your hand or Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Add 1 Level 5 or higher WIND Dragon monster from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_names={46384672} --"Armed Dragon LV5"
s.listed_series={SET_ARMED_DRAGON}
s.LVnum=5
s.LVset=SET_ARMED_DRAGON_THUNDER
function s.spcostfilter(c,e,tp,armd_lv5)
	return c:IsMonster() and c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,c,e,tp,armd_lv5)
end
function s.spfilter(c,e,tp,armd_lv5)
	local ignore_sum_con=c:IsCode(73879377) and armd_lv5
	return c:IsSetCard(SET_ARMED_DRAGON) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,ignore_sum_con,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local armd_lv5=e:GetHandler():IsCode(46384672)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,nil,e,tp,armd_lv5) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,armd_lv5)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local armd_lv5=false
	if c:IsCode(46384672) and c:IsFaceup() then
		armd_lv5=true
	else
		local trig_code1,trig_code2=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
		armd_lv5=trig_code1==46384672 or trig_code2==46384672
	end
	if Duel.SendtoGrave(c,REASON_EFFECT)>0 and c:IsLocation(LOCATION_GRAVE)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp,armd_lv5):GetFirst()
		if not sc then return end
		local armd_lv7=sc:IsCode(73879377)
		ignore_sum_con=armd_lv5 and armd_lv7
		if Duel.SpecialSummon(sc,0,tp,tp,ignore_sum_con,false,POS_FACEUP)>0 and armd_lv7 then
			sc:CompleteProcedure()
		end
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not (e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsMonsterEffect()) then return false end
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsFaceup() then
		return rc:IsRace(RACE_DRAGON)
	else
		return Duel.GetChainInfo(0,CHAININFO_TRIGGERING_RACE)&RACE_DRAGON>0
	end
end
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end