--トレジャー・パンダー
--Treasure Panda
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Normal Monster from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsSpellTrap() and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
function s.rescon(sg,e,tp,mg)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,#sg,false)
end
function s.spfilter(c,e,tp,lvl,chk)
	if not (c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	return (chk and c:IsLevelBelow(lvl)) or c:IsLevel(lvl)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=math.min(#g,3)
	if chk==0 then return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ct,true) end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,ct,s.rescon,1,tp,HINTMSG_REMOVE,s.rescon)
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
	e:SetLabel(#rg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local lvl=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lvl,false)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end