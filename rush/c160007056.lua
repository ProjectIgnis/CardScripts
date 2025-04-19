-- カンバック！カンショック！！
--Shocking Comeback!!
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Gain LP
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.lpcon)
	e1:SetTarget(s.lptg)
	e1:SetOperation(s.lpop)
	c:RegisterEffect(e1)
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.GetAttacker():IsLevelAbove(6)
end
function s.lpfilter(c)
	return c:IsRace(RACE_PSYCHIC) and c:IsLevelBelow(6) and c:GetAttack()>0
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
	Duel.SetChainLimit(function(e)return not e:IsHasType(EFFECT_TYPE_ACTIVATE)end)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.lpfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	local rec=Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	if rec>=1000 and tc:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end