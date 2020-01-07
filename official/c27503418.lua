--王者の調和
--King's Synchro
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsType(TYPE_SYNCHRO)
end
function s.filter1(c,e,tp,tc,lv)
	local rlv=c:GetLevel()-lv
	return rlv>0 and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c,tp,rlv)
end
function s.filter2(c,tp,lv)
	local rlv=lv-c:GetLevel()
	return rlv==0 and c:IsType(TYPE_TUNER) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	if Duel.NegateAttack() and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc,tc:GetLevel())
		and tc:IsAbleToRemove() and #pg<=0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetLevel())
		local lv=g1:GetFirst():GetLevel()-tc:GetLevel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp,lv)
		g2:AddCard(tc)
		if Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)==2 then
			Duel.SpecialSummon(g1,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			g1:GetFirst():CompleteProcedure()
		end
	end
end
