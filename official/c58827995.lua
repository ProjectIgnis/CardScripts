--鎧竜降臨
--Armor Dragon Ritual
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreaterCode(c,4,nil,75901113)
	--Special summon 1 "Paladin of Armored Dragon" from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetCondition(aux.exccon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
	--Specifically lists "Paladin of Armored Dragon"
s.listed_names={75901113}
function s.rescon(sg,e,tp,mg)
	return sg:GetSum(Card.GetLevel)>=4
end
function s.costfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:GetOriginalLevel()>0 and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
	--Banish monsters whose total levels equal 4 as cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,1,99,s.rescon,0) end
	local sg=aux.SelectUnselectGroup(rg,e,tp,1,99,s.rescon,1,tp,HINTMSG_REMOVE,nil,s.rescon)
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
	--Check for "Paladin of Armored Dragon"
function s.spfilter(c,e,tp)
	return c:IsCode(75901113) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
	--Banish itself from GY, and if you do, special summon 1 "Paladin of Armored Dragon" from GY
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end