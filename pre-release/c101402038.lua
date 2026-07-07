--召喚獣ディー・アニマ
--Invoked Dee Anima
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "Aleister" monster + 1 monster Special Summoned from the Extra Deck
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ALEISTER),s.exdmatfilter)
	--If this card is Special Summoned: You can activate 1 of these effects;
	--● Destroy all monsters your opponent controls that were Special Summoned from the Extra Deck
	--● Destroy all Spells/Traps your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--When your opponent activates a card effect in the GY (Quick Effect): You can banish this card; Special Summon 1 "Aleister" monster from your Deck, and if you do, negate that effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp,chk)
		return ep==1-tp and Chain.IsTriggeringLocation(ev,LOCATION_GRAVE) and Duel.IsChainDisablable(ev)
	end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ALEISTER}
s.material_setcode={SET_ALEISTER}
function s.exdmatfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(Card.IsSummonLocation,tp,0,LOCATION_MZONE,nil,LOCATION_EXTRA)
	local g2=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	local b1=#g1>0
	local b2=#g2>0
	if chk==0 then return b1 or b2 end
	local cd=e:GetChainData()
	cd.choice=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	local g=(cd.choice==1 and g1 or g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	if cd.choice==1 then
		--● Destroy all monsters your opponent controls that were Special Summoned from the Extra Deck
		local g=Duel.GetMatchingGroup(Card.IsSummonLocation,tp,0,LOCATION_MZONE,nil,LOCATION_EXTRA)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif cd.choice==2 then
		--● Destroy all Spells/Traps your opponent controls
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ALEISTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.NegateEffect(ev)
	end
end