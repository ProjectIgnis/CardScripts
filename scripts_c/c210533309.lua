--Holy Quintet
function c210533309.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c210533309.target)
	e1:SetOperation(c210533309.operation)
	c:RegisterEffect(e1)
end
function c210533309.filter(c)
	return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM)
end
function c210533309.filter1(c)
	return c210533309.filter(c) and c:IsAbleToHand()
end
function c210533309.filter2(c)
	return c210533309.filter(c) and c:IsFaceup()
end
function c210533309.filter3(c)
	return c210533309.filter(c) and c:IsAbleToHand() and c:IsFaceup()
end
function c210533309.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c210533309.filter2,tp,LOCATION_MZONE,0,nil)
	local gtg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	local ct=g:GetClassCount(Card.GetCode)
	local con1=ct>=1 and Duel.IsExistingMatchingCard(c210533309.filter1,tp,LOCATION_DECK,0,1,nil)
	local con2=ct>=2 and Duel.IsExistingMatchingCard(c210533309.filter2,tp,LOCATION_MZONE,0,1,nil)
	local con3=ct>=3 and Duel.IsExistingMatchingCard(c210533309.filter3,tp,LOCATION_EXTRA,0,1,nil)
	local con4=ct>=4
	local con5=ct==5 and #gtg>0
	if chk==0 then return con1 or con2 or con3 or con4 or con5 end
	e:SetCategory(0)
	if con1 then
		e:SetCategory(e:GetCategory()|CATEGORY_TOHAND|CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	if con2 then
		e:SetCategory(e:GetCategory()|CATEGORY_ATKCHANGE)
	end
	if con3 then
		e:SetCategory(e:GetCategory()|CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	end
	if con4 then
		e:SetCategory(e:GetCategory()|CATEGORY_DAMAGE)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	end
	if con5 then
		e:SetCategory(e:GetCategory()|CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,gtg,#gtg,0,0)
	end
end
function c210533309.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c210533309.filter2,tp,LOCATION_MZONE,0,nil)
	local gtg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if ct>=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local th=Duel.SelectMatchingCard(tp,c210533309.filter1,tp,LOCATION_DECK,0,1,1,nil)
		if #th>0 then
			Duel.SendtoHand(th,tp,REASON_EFFECT)
		end
	end
	if ct>=2 and Duel.IsExistingMatchingCard(c210533309.filter2,tp,LOCATION_MZONE,0,1,nil) then
		Duel.BreakEffect()
		local ag=Duel.GetMatchingGroup(c210533309.filter2,tp,LOCATION_MZONE,0,nil)
		for tc in aux.Next(ag) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(500)
			tc:RegisterEffect(e1)
		end
	end
	if ct>=3 and Duel.IsExistingMatchingCard(c210533309.filter3,tp,LOCATION_EXTRA,0,1,nil) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local th=Duel.SelectMatchingCard(tp,c210533309.filter3,tp,LOCATION_EXTRA,0,1,2,nil)
		if #th>0 then
			Duel.SendtoHand(th,tp,REASON_EFFECT)
		end	 
	end
	if ct>=4 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
	if ct==5 and #gtg>0 then
		Duel.BreakEffect()
		Duel.SendtoGrave(gtg,REASON_EFFECT)
	end
end