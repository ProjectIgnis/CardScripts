--エヴォルド・メガキレラ
--Evoltile Megachirella
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Level 4 or lower FIRE Dinosaur monster from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Attach up to 2 Reptile/Dinosaur monsters to a Dragon Xyz monster you control with no material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.SelfBanishCost)
	e2:SetTarget(s.atchtg)
	e2:SetOperation(s.atchop)
	c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,SUMMON_BY_EVOLTILE,tp,false,false,POS_FACEUP)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsRace,1,false,aux.ReleaseCheckMMZ,nil,RACE_REPTILE)
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	local sg=Duel.SelectReleaseGroupCost(tp,Card.IsRace,1,1,false,aux.ReleaseCheckMMZ,nil,RACE_REPTILE)
	Duel.Release(sg,REASON_COST)
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g then
		Duel.SpecialSummon(g,SUMMON_BY_EVOLTILE,tp,tp,false,false,POS_FACEUP)
	end
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
function s.atchtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,e:GetHandler(),RACE_REPTILE|RACE_DINOSAUR) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atchop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e)
		and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,RACE_REPTILE|RACE_DINOSAUR) then
		local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,RACE_REPTILE|RACE_DINOSAUR)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,2,aux.dncheck,1,tp,HINTMSG_XMATERIAL)
		if #sg>0 then
			Duel.Overlay(tc,sg)
		end
	end
end