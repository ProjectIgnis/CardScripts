--イルミネーション
--Illumination
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	e:SetLabel(op)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	if e:GetLabel()==0 then
		--Negate an effect that would negate a Normal or Special Summon
		e1:SetCondition(s.condition1)
	else
		--Negate an effect that would destroy a monster(s)
		e1:SetCondition(s.condition2)
	end
	e1:SetOperation(s.operation)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg=Duel.GetOperationInfo(ev,CATEGORY_DISABLE_SUMMON)
	return ex and tg~=nil and tg:IsExists(Card.IsSummonType,1,nil,SUMMON_TYPE_NORMAL|SUMMON_TYPE_SPECIAL) 
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsMonster,nil)-#tg>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
