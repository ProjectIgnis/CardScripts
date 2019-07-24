--Dark Computer Virus
local s,id=GetID()
function s.initial_effect(c)
	--effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.tcfilter(tc,ec,tp,eg,ep,ev,re,r,rp)
	local te=ec:GetActivateEffect()
	if te then
		local tg=te:GetTarget()
		return tg and tg(te,tp,eg,ep,ev,re,r,rp,0,tc)
	end
	return false
end
function s.ecfilter(c,tp,eg,ep,ev,re,r,rp)
	return c:GetType()&TYPE_SPELL+TYPE_CONTINUOUS==TYPE_SPELL+TYPE_CONTINUOUS and c:GetCardTargetCount()==1 
		and Duel.IsExistingMatchingCard(s.tcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c:GetFirstCardTarget(),c,tp,eg,ep,ev,re,r,rp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ecfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,tp,eg,ep,ev,re,r,rp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43641473,0))
	local g=Duel.SelectMatchingCard(tp,s.ecfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		local tg=Duel.SelectMatchingCard(tp,s.tcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc:GetFirstCardTarget(),tc,tp,
			eg,ep,ev,re,r,rp):GetFirst()
		tc:CancelCardTarget(tc:GetFirstCardTarget())
		tc:SetCardTarget(tg)
	end
end
