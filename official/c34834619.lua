--光子竜降臨
--Luminous Dragon Ritual
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon 1 "Paladin of Photon Dragon" from your hand
	Ritual.AddProcEqualCode(c,4,nil,85346853)
	--Banish monsters from your GY whose total Levels equal exactly 4, then Special Summon 1 "Paladin of Photon Dragon" from your hand (this is treated as a Ritual Summon)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={85346853} --"Paladin of Photon Dragon"
function s.rmfilter(c,e,tp)
	return c:HasLevel() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e) and aux.SpElimFilter(c,true)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 and sg:GetSum(Card.GetLevel)==4
end
function s.spfilter(c,e,tp)
	return c:IsCode(85346853) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local rg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,e,tp)
		return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,4,s.rescon,0)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,e,tp)
	if #g==0 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,4,s.rescon,1,tp,HINTMSG_REMOVE)
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 and rg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
		end
	end
end