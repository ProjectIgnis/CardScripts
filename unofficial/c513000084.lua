--エコール・ド・ゾーン
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(500000147,0))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e4)
	--successful summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(500000147,0))
	e5:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_F)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetTarget(s.destg2)
	e5:SetOperation(s.desop2)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7)
	--cannot direct attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e4)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCurrentChain()==0 end
	local ct=#eg
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
	local tc=eg:GetFirst()
	while tc do
		local token=Duel.CreateToken(tp,500000148)
		Duel.SpecialSummonStep(token,0,tc:GetPreviousControler(),tc:GetPreviousControler(),false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(tc:GetBaseDefense())
		token:RegisterEffect(e2)
		tc=eg:GetNext()
	end
	Duel.SpecialSummonComplete()
end
function s.filter(c,re,e)
	return c:IsFaceup() and (not re or re:GetOwner()~=e:GetOwner())
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return eg:IsExists(s.filter,1,nil,re,e) end
	local ct=#eg
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
	local tc=eg:GetFirst()
	while tc do
		if not tc:IsLocation(LOCATION_MZONE) then
			local token=Duel.CreateToken(tp,500000148)
			Duel.SpecialSummonStep(token,0,tc:GetPreviousControler(),tc:GetPreviousControler(),false,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_BASE_DEFENSE)
			e2:SetValue(tc:GetBaseDefense())
			token:RegisterEffect(e2)
		end
		tc=eg:GetNext()
	end
	Duel.SpecialSummonComplete()
end
