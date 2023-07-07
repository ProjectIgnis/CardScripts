--スリーカード召喚
--Three Card Summon
--Made by When
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.spcost)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLevel)==1
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and aux.SelectUnselectGroup(g,e,tp,3,3,s.spcheck,0) end
    local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.spcheck,1,tp,HINTMSG_CONFIRM)
	sg:KeepAlive()
    e:SetLabelObject(sg)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local sg=e:GetLabelObject()
	if #sg>0 then
		Duel.SpecialSummon(sg:Select(tp,1,1,nil):GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	end
end
