--The Roids are Alright
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_names={23299957}
s.listed_series={0x16}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.AdjustInstantly()
	local c=e:GetHandler()
	--"Vehicroid Connection Zone" can Fusion Summon any 'roid Fusion Monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_ADJUST)
	e0:SetRange(0x5f)
	e0:SetOperation(s.vczop)
	Duel.RegisterEffect(e0,tp)
	--Normal Summon/Set Level 6 or lower 'roids without Tributing
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_SUMMON_PROC)
	e1a:SetRange(0x5f)
	e1a:SetTargetRange(LOCATION_HAND,0)
	e1a:SetCondition(s.ntcon)
	e1a:SetTarget(aux.FieldSummonProcTg(s.nttg))
	Duel.RegisterEffect(e1a,tp)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_SET_PROC)
	Duel.RegisterEffect(e1b,tp)	
	--Level 6 or lower non-Fusion 'roids gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(0x5f)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(function(e,c) return c:GetLevel()*100 end)
	Duel.RegisterEffect(e2,tp)
	--Flip this card over if you control a non-Machine monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.flipcon2)
	e3:SetOperation(s.flipop2)
	Duel.RegisterEffect(e3,tp)
end
--VCZ overwrite functions
function s.vczop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_ALL,LOCATION_ALL,nil,23299957)
	for tc in g:Iter() do
		tc:RegisterFlagEffect(id,0,0,0)
		local eff=tc:GetActivateEffect()
		eff:Reset()
		tc:RegisterEffect(Fusion.CreateSummonEff(tc,aux.FilterBoolFunction(Card.IsSetCard,0x16),nil,nil,nil,nil,s.stage2))
	end
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		local c=e:GetHandler()
		--Cannot be destroyed by card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3001)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--Cannot be negated
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3308)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetValue(s.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
	end
end
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end
--Normal Summon functions
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return (c:GetOriginalLevel()==6 or c:GetOriginalLevel()==5)  and c:IsSetCard(0x16)
end
--Attack declaration functions
function s.atkfilter(c)
	return c:IsSetCard(0x16) and c:IsRace(RACE_MACHINE) and not c:IsType(TYPE_FUSION) and c:GetOriginalLevel()<7
end
function s.atkcon(e)
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget()~=nil
end
function s.atktg(e,c)
	return s.atkfilter(c) and Duel.GetAttacker()==c
end
--Flip-over functions
function s.cfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_MACHINE)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.vczfilter(c)
	return c:IsCode(23299957) and c:GetFlagEffect(id)>0
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.vczfilter,tp,LOCATION_ALL,LOCATION_ALL,nil)
	for sc in sg:Iter() do
		local eff=sc:GetActivateEffect()
		eff:Reset()
		sc:RegisterEffect(Fusion.CreateSummonEff(sc,aux.FilterBoolFunction(Card.IsSetCard,0x1016),nil,nil,nil,nil,s.stage2))
	end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
end