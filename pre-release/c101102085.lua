--
--Myutant ST-46
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x259}
s.listed_names={101102087,101102088,101102089}
function s.thfilter(c)
	return c:IsSetCard(0x259) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
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
function s.smnfilter(c,e,tp,...)
	return c:IsCode(...) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcfilter(c,e,tp)
	return ((c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup()) or c:IsLocation(LOCATION_HAND)) and c:IsAbleToRemoveAsCost()
		and ((c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.smnfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,c,e,tp,101102087))
			or (c:IsType(TYPE_SPELL) and Duel.IsExistingMatchingCard(s.smnfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,c,e,tp,101102088))
			or (c:IsType(TYPE_TRAP) and Duel.IsExistingMatchingCard(s.smnfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,c,e,tp,101102089)))
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_MZONE
	if e:GetHandler():GetSequence()<5 then loc=LOCATION_ONFIELD|LOCATION_HAND end
	if chk==0 then return e:GetHandler():IsReleasable() and Duel.IsExistingMatchingCard(s.spcfilter,tp,loc,0,1,e:GetHandler(),e,tp) end
	Duel.Release(e:GetHandler(),REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=Duel.SelectMatchingCard(tp,s.spcfilter,tp,loc,0,1,1,e:GetHandler(),e,tp)
	e:SetLabel(rg:GetFirst():GetType())
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or e:GetHandler():GetSequence()<5 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local type=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and type then return end
	local ids={}
	if type&TYPE_MONSTER==TYPE_MONSTER then ids[#ids+1]=101102087 end
	if type&TYPE_SPELL==TYPE_SPELL then ids[#ids+1]=101102088 end
	if type&TYPE_TRAP==TYPE_TRAP then ids[#ids+1]=101102089 end
	if #ids>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.smnfilter,tp,LOCATION_DECK|LOCATION_HAND,0,1,1,nil,e,tp,table.unpack(ids))
		if #g>0 then Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP) end
	end
end