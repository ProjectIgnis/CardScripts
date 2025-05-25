--灰滅の劫火
--Inferno of the Ashened
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: You can place 1 "Obsidim, the Ashened City" from your Deck face-up in either Field Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Send 1 face-up card your opponent controls to the GY and Special Summon 1 Level 8 or higher DARK Pyro monster from your GY to your opponent's field in Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tgsptg)
	e2:SetOperation(s.tgspop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_OBSIDIM_ASHENED_CITY}
function s.plfilter(c)
	return c:IsCode(CARD_OBSIDIM_ASHENED_CITY) and not c:IsForbidden()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_DECK,0,nil,tp)
	if Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if sc then
			local op=Duel.SelectOption(tp,false,aux.Stringid(id,3),aux.Stringid(id,4))
			local target_player=op==0 and tp or 1-tp
			Duel.MoveToField(sc,tp,target_player,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end
function s.tgfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToGrave() and Duel.GetMZoneCount(1-tp,c)>0
end
function s.spfilter(c,e,tp)
	return c:IsLevelAbove(8) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_PYRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
function s.tgsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil,tp)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,tp,0)
end
function s.tgspop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local fg,gg=tg:Split(Card.IsLocation,nil,LOCATION_ONFIELD)
	if #fg>0 and Duel.SendtoGrave(fg,REASON_EFFECT)>0 and fg:GetFirst():IsLocation(LOCATION_GRAVE)
		and #gg>0 then
		Duel.SpecialSummon(gg,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end