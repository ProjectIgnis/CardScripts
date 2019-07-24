--Junk Anchor (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--synchro
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.sccost)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
end
function s.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST)
end
function s.mfilter(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsSetCard(0x43) and not c:IsType(TYPE_TUNER) 
		and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
function s.scfilter(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local tc=Duel.SelectMatchingCard(tp,s.mfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetHandler()):GetFirst()
	local mg=Group.FromCards(tc,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg):GetFirst()
	if sc then Duel.SynchroSummon(tp,sc,nil,mg) end
end
