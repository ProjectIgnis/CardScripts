--真竜皇リトスアジムD
--True King Lithosagym, the Disaster
local CARD_TRUE_KING_CALAMITIES=88581108
local s,id=GetID()
function s.initial_effect(c)
	--Special summon itself from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Special summon a monster from the graveyard
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
function s.desfilter(c)
	return c:IsMonster() and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_HAND))
end
function s.locfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH) and Duel.GetMZoneCount(tp,sg)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local opp_mzone=Duel.IsPlayerAffectedByEffect(tp,CARD_TRUE_KING_CALAMITIES) and LOCATION_MZONE or 0 --True King of All Calamities
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE|LOCATION_HAND,opp_mzone,c)
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	if (#g==2 and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)==1) or not g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,tp,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_MZONE|LOCATION_HAND)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opp_mzone=Duel.IsPlayerAffectedByEffect(tp,CARD_TRUE_KING_CALAMITIES) and LOCATION_MZONE or 0 --True King of All Calamities
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE|LOCATION_HAND,opp_mzone,c)
	if #g<2 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH) then return end
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY)
	if #dg<2 then return end
	local rmv_chk=dg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_EARTH)==2 and true or false
	if Duel.Destroy(dg,REASON_EFFECT)==2 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and rmv_chk then
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
		if rmv_chk and #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.ConfirmCards(tp,rg)
			local rmv_g=aux.SelectUnselectGroup(rg,e,tp,1,3,aux.dncheck,1,tp,HINTMSG_REMOVE)
			if #rmv_g>0 then
				Duel.Remove(rmv_g,POS_FACEUP,REASON_EFFECT)
			end
			Duel.ShuffleExtra(1-tp)
		end
	end
end
function s.thfilter(c,e,tp)
	return c:IsAttributeExcept(ATTRIBUTE_EARTH) and c:IsRace(RACE_WYRM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end