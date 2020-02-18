--ヒヤリ＠イグニスター (Anime)
--Hiyari @Ignister (Anime)
--Scripted by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(alias,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(alias,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={85327820}
s.listed_series={0x135}
function s.filter(c)
	return c:IsType(TYPE_LINK) and c:IsFaceup() and c:GetSequence()>4
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
function s.zonefilter(tp)
	local lg=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_MZONE,0,nil)
	local zone=0
	for tc in aux.Next(lg) do
		zone=zone|tc:GetLinkedZone()
	end 
	return zone
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zones=s.zonefilter(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zones) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zones=s.zonefilter(tp)
	if not e:GetHandler():IsRelateToEffect(e) or zones==0 then return end
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP,zones)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,nil,e:GetHandler(),0x135) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,nil,e:GetHandler(),0x135)
	Duel.Release(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function s.thfilter(c)
	return c:IsCode(85327820) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsSetCard(0x135) and c:IsRitualMonster() and c:IsAbleToHand()
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
	local lc=e:GetLabelObject()
	if lc:IsType(TYPE_LINK) then
		local tg=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,nil)
		if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(alias,2)) then
			Duel.SendtoHand(tg:Select(tp,1,1,nil),nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,Duel.GetOperatedGroup())
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(lc:GetLink())
		e:GetHandler():RegisterEffect(e1)
	end
end
