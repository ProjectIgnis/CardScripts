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
function s.rescon(lv2)
	return function(sg,e,tp,mg)
		return #sg~=2 or lv2
	end
end
function s.spfilter1(c,e,tp,lvl)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(lvl) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=math.min(#g,3)
	local dg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp,ct)
	if chk==0 then return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #dg>0 end
	local _,min=dg:GetMinGroup(Card.GetLevel)
	local _,max=dg:GetMaxGroup(Card.GetLevel)
	local res=s.rescon(dg:IsExists(Card.IsLevel,1,nil,2))
	local rg=aux.SelectUnselectGroup(g,e,tp,min,max,res,1,tp,HINTMSG_REMOVE,res)
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
	e:SetLabel(#rg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter2(c,e,tp,lvl)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(lvl) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local lvl=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,lvl)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
