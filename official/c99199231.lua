--Ｓ－Ｆｏｒｃｅ オリジン
--S-Force Origin
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "S-Force" monster from your hand, GY, or banishment, but banish it when it leaves the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If another card(s) is banished while this card is in your GY: You can banish it; take 2 "S-Force" cards from your Deck, except "S-Force Origin", banish 1 of them, and send the other to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.bantgtg)
	e2:SetOperation(s.bantgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_S_FORCE}
s.listed_names={id}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_S_FORCE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it when it leaves the field
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		sc:RegisterEffect(e1,true)
	end
end
function s.bantgfilter(c)
	return c:IsSetCard(SET_S_FORCE) and (c:IsAbleToRemove() or c:IsAbleToGrave()) and not c:IsCode(id)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsAbleToRemove,1,nil) and sg:IsExists(Card.IsAbleToGrave,1,nil)
end
function s.bantgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.bantgfilter,tp,LOCATION_DECK,0,nil)
		return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.banfilter(c,sg)
	return c:IsAbleToRemove() and sg:IsExists(Card.IsAbleToGrave,1,c)
end
function s.bantgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.bantgfilter,tp,LOCATION_DECK,0,nil)
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,2))
	if #sg~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local bg=sg:FilterSelect(tp,s.banfilter,1,1,nil,sg)
	if #bg>0 then
		Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)
		Duel.SendtoGrave(sg-bg,REASON_EFFECT)
	end
end