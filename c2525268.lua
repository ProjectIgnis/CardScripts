--魔導騎士 ディフェンダー
--Defender, the Magical Knight
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL)
	c:SetCounterLimit(COUNTER_SPELL,1)
	--summon success
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.addct)
	e1:SetOperation(s.addc)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetValue(s.value)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.counter_list={COUNTER_SPELL}
function s.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_SPELL)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(COUNTER_SPELL,1)
	end
end
function s.dfilter(c)
	return not c:IsReason(REASON_REPLACE) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(s.dfilter,nil)
		e:SetLabel(count)
		return count>0 and Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,count,REASON_COST)
	end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.value(e,c)
	return c:IsFaceup() and c:GetLocation()==LOCATION_MZONE and c:IsRace(RACE_SPELLCASTER)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,count,REASON_COST)
end
