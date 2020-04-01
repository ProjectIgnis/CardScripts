--魔轟神ディアネイラ
--Fabled Dianaira
local s,id=GetID()
function s.initial_effect(c)
	--summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--change effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.chcon1)
	e2:SetOperation(s.chop1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_ACTIVATING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.chcon2)
	e3:SetOperation(s.chop2)
	c:RegisterEffect(e3)
end
s.listed_series={0x35}
function s.otfilter(c,tp)
	return c:IsSetCard(0x35) and (c:IsControler(tp) or c:IsFaceup())
end
function s.chcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:GetHandler():GetType()==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.chop1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.chcon2(e,tp,eg,ep,ev,re,r,rp)
	return ev==1 and e:GetHandler():GetFlagEffect(id)>0
end
function s.chop2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.ChangeChainOperation(1,s.rep_op)
end
function s.rep_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
end
