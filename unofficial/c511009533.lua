--En Flowers
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--eff
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1353770,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code) and c:GetSequence()<5
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil,id+1)
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_SZONE,0,1,nil,511009535)
		and Duel.IsExistingMatchingCard(s.cfilter3,tp,LOCATION_SZONE,0,1,nil,511009536)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.disfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.disfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.filter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.disfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		if tc:RegisterEffect(e1)>0 and tc:RegisterEffect(e2)>0 then
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,0)
		end
		tc=g:GetNext()
	end
	g=g:Filter(function(c) return c:GetFlagEffect(id)>0 end,nil)
	if Duel.Destroy(g,REASON_EFFECT)<=0 then return end
	local ct1=g:FilterCount(s.filter,nil,tp)
	local ct2=g:FilterCount(s.filter,nil,1-tp)
	Duel.BreakEffect()
	Duel.Damage(tp,ct1*600,REASON_EFFECT,true)
	Duel.Damage(1-tp,ct2*600,REASON_EFFECT,true)
	Duel.RDComplete()
end
