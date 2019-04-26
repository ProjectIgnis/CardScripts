--闇晦ましの城
local s,id=GetID()
function s.initial_effect(c)
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_MONSTER)
	if #g<=0 then return end
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(id)==0 then
			tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
			--no tribute
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(10000080,1))
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LIMIT_SET_PROC)
			e1:SetCondition(s.ntcon)
			e1:SetOperation(s.ntop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			--1 tribute
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(aux.Stringid(10000080,1))
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_LIMIT_SET_PROC)
			e2:SetCondition(s.tcon)
			e2:SetOperation(s.top)
			e2:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			--2 tribute
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetDescription(aux.Stringid(10000080,1))
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_LIMIT_SET_PROC)
			e3:SetCondition(s.ttcon)
			e3:SetOperation(s.ttop)
			e3:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end		
end
function s.spchk(c)
	return c:IsFaceup() and not c:IsStatus(STATUS_DISABLED) and c:IsOriginalCode(id)
end
function s.ntcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and c:GetLevel()<=4
end
function s.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	if Duel.IsExistingMatchingCard(s.spchk,tp,LOCATION_MZONE,0,1,nil) then
		e:SetTargetRange(POS_FACEDOWN,0)
	else
		e:SetTargetRange(POS_FACEDOWN_DEFENSE,0)
	end
end
function s.tcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-1 and (c:GetLevel()==5 or c:GetLevel()==6) 
		and Duel.GetTributeCount(c)>=1
end
function s.top(e,tp,eg,ep,ev,re,r,rp,c)
	if Duel.IsExistingMatchingCard(s.spchk,tp,LOCATION_MZONE,0,1,nil) then
		e:SetTargetRange(POS_FACEDOWN,0)
	else
		e:SetTargetRange(POS_FACEDOWN_DEFENSE,0)
	end
	local g=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
function s.ttcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-2 and Duel.GetTributeCount(c)>=2 
		and c:GetLevel()>=7
end
function s.ttop(e,tp,eg,ep,ev,re,r,rp,c)
	if Duel.IsExistingMatchingCard(s.spchk,tp,LOCATION_MZONE,0,1,nil) then
		e:SetTargetRange(POS_FACEDOWN,0)
	else
		e:SetTargetRange(POS_FACEDOWN_DEFENSE,0)
	end
	local g=Duel.SelectTribute(tp,c,2,2)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
