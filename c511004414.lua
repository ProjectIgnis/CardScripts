--Protector Adoration
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,1,s.filter,CATEGORY_DISABLE,nil,nil,TIMING_END_PHASE,nil,nil,s.target,s.operation,true)
	--cannot attack/disable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(aux.TargetBoolFunction(Card.IsCode,511009337))
	c:RegisterEffect(e2)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--destroy 2
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.desucon)
	e5:SetOperation(s.desuop)
	c:RegisterEffect(e5)
end
s.listed_names={511009337}
function s.desucon(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetFirstCardTarget()
	if not ec then return false end
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,511009337)
	local ag=ec:GetAttackedGroup()
	local tc=ag:GetFirst()
	while tc do
		if ag:IsContains(tc) then g:RemoveCard(tc) end
		tc=ag:GetNext()
	end
	return #g>0
end
function s.desuop(e,tp,eg,ev,ep,re,r,rp)
	local ec=e:GetHandler():GetFirstCardTarget()
	Duel.Destroy(ec,REASON_EFFECT)
end
function s.filter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,511009337,0,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
	if c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(14089428,0)) then
		for i=1,2 do
			local token=Duel.CreateToken(tp,511009337)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
