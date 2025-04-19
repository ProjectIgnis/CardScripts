--七皇の双璧
--Duo of the Seven Emperors
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
s.listed_series={0x1048}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return ep==tp and ((a:IsSetCard(SET_NUMBER_C) and a:IsControler(1-tp)) or (d and d:IsSetCard(SET_NUMBER_C) and d:IsControler(1-tp)))
end
function s.spfilter(c,code,e,tp)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>1
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.CheckSummonGate(tp,2) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,20785975,e,tp)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,67173574,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or not aux.CheckSummonGate(tp,2) then return end
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,20785975,e,tp)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,67173574,e,tp)
	if #g1>0 and #g2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		local tc=sg1:GetFirst()
		for tc in aux.Next(sg1) do
			Duel.SpecialSummonStep(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
			tc:CompleteProcedure()
		end
		Duel.SpecialSummonComplete()
	end
end