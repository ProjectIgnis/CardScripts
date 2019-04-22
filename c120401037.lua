--マドルチェ・クリームー
--Madolche Creamoo
--Scripted by Eerie Code
function c120401037.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x71),2,2)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,120401037)
	e1:SetCondition(c120401037.thcon)
	e1:SetTarget(c120401037.thtg)
	e1:SetOperation(c120401037.thop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(120401037,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,120401037+100)
	e2:SetCost(c120401037.spcost)
	e2:SetTarget(c120401037.sptg)
	e2:SetOperation(c120401037.spop)
	c:RegisterEffect(e2)
end
function c120401037.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c120401037.thfilter(c)
	return c:IsSetCard(0x71) and c:IsAbleToHand()
end
function c120401037.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c120401037.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c120401037.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c120401037.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c120401037.spcfilter(c,e,tp,g,zone)
	if (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) 
		and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x71) and c:IsAbleToGraveAsCost()
		and (zone~=0 or g:IsContains(c)) and c:GetLevel()>0 then
		if zone==0 then
			return Duel.IsExistingMatchingCard(c120401037.spfilter0,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),e,tp)
		else
			return Duel.IsExistingMatchingCard(c120401037.spfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),e,tp,zone)
		end
	else return false end
end
function c120401037.spfilter0(c,lv,e,tp)
	return c:IsSetCard(0x71) and c:GetLevel()==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c120401037.spfilter(c,lv,e,tp,zone)
	return c:IsSetCard(0x71) and c:GetLevel()==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function c120401037.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local zone=c:GetLinkedZone()
	if chk==0 then return Duel.IsExistingMatchingCard(c120401037.spcfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,c,e,tp,lg,zone) end
	local tc=Duel.SelectMatchingCard(tp,c120401037.spcfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,c,e,tp,lg,zone):GetFirst()
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetLabel(tc:GetLevel())
end
function c120401037.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c120401037.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone()
	if zone==0 then return end
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c120401037.spfilter,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp,zone)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
