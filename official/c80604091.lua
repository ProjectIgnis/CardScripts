--血の代償
--Ultimate Offering
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--instant
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSummonable(true,nil) or c:IsMSetable(true,nil)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tn=Duel.GetTurnPlayer()
	return (tn==tp and Duel.IsMainPhase()) or (tn~=tp and Duel.IsBattlePhase())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	if e:GetHandler():GetFlagEffect(id)==0 then
		e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1,Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil))
	end
	Duel.PayLPCost(tp,500)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetHandler():GetFlagEffect(id)==0 then
			return Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)>0
		else return e:GetHandler():GetFlagEffectLabel(id)>0 end
	end
	e:GetHandler():SetFlagEffectLabel(id,e:GetHandler():GetFlagEffectLabel(id)-1)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(true,nil)
		local s2=tc:IsMSetable(true,nil)
		if (s1 and s2 and Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)==POS_FACEUP_ATTACK) or not s2 then
			Duel.Summon(tp,tc,true,nil)
		else
			Duel.MSet(tp,tc,true,nil)
		end
	end
end
