--Commande Duel JP002
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c.illegal and c:IsType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_DECK+LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.filter,1-tp,LOCATION_EXTRA,0,nil,e,tp)
	if #g1>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(102380,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg1=g1:Select(tp,1,1,nil)
		if Duel.SpecialSummonStep(sg1:GetFirst(),0,tp,tp,true,false,POS_FACEUP) and Duel.SelectYesNo(0,aux.Stringid(1102515,0)) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
	if #g2>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(102380,0)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local sg2=g2:Select(1-tp,1,1,nil)
		if Duel.SpecialSummonStep(sg2:GetFirst(),0,1-tp,1-tp,true,false,POS_FACEUP) and Duel.SelectYesNo(1,aux.Stringid(1102515,0)) then
			Duel.Draw(1-tp,1,REASON_EFFECT)
		end
	end
	Duel.SpecialSummonComplete()
end
