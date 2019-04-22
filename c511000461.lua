--Monster Replace
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_BECOME_QUICK)
	e2:SetRange(LOCATION_SZONE+LOCATION_HAND)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
end
function s.condition(e)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_HAND) then
		return c:IsHasEffect(EFFECT_TRAP_ACT_IN_HAND)
	elseif c:IsLocation(LOCATION_SZONE) then
		return Duel.GetTurnCount()~=c:GetTurnID() or c:IsHasEffect(EFFECT_TRAP_ACT_IN_SET_TURN)
	end
	return false
end
function s.filter(c,e,tp,ft)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,c,TYPE_MONSTER)
	local tg=g:GetMaxGroup(Card.GetAttack)
	return c:IsAbleToHand() and (ft>0 or c:GetSequence()<5) and tg 
		and tg:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false,c:GetPosition(),tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e,tp,ft) end
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local pos=tc:GetPosition()
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
			local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,tc,TYPE_MONSTER)
			local tg=g:GetMaxGroup(Card.GetAttack)
			if not tg then return false end
			if #tg>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				tg=tg:FilterSelect(tp,Card.IsCanBeSpecialSummoned,1,1,nil,e,0,tp,false,false,pos,tp)
			end
			Duel.SpecialSummon(tg,0,tp,tp,false,false,pos)
		end
	end
end
