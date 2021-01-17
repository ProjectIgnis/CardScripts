--スター・マイン
--Star Mine
--scripted by senpaizuri
local s,id=GetID()
function s.initial_effect(c)
	--SS limit
	c:SetSPSummonOnce(id)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--damage1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.damcon1)
	e1:SetTarget(s.damtg1)
	e1:SetOperation(s.damop1)
	c:RegisterEffect(e1)
	--damage2
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.damcon2)
	e2:SetTarget(s.damtg2)
	e2:SetOperation(s.damop2)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.filter(c,tp,rp)
	local ac=Duel.GetAttacker()
	if c:IsReason(REASON_BATTLE) and ac and ac~=c then
		if ac:IsLocation(LOCATION_MZONE) then return ac:IsControler(1-tp) else return ac:IsPreviousControler(1-tp) end
	elseif c:IsReason(REASON_EFFECT) and rp~=tp then
		return true
	end
	return false
end
function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return s.filter(e:GetHandler(),tp,rp) and e:GetHandler():IsPreviousControler(tp)
end
function s.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.Damage(tp,2000,REASON_EFFECT)
	if val>0 and Duel.GetLP(tp)>0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
end
function s.cfilter(c,tp,seq)
	if not c:IsPreviousControler(tp) or not c:IsPreviousLocation(LOCATION_MZONE) then return false end
	return (seq-1>=0 and c:GetPreviousSequence()==seq-1) or (seq+1<=4 and c:GetPreviousSequence()==seq+1)
end
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:Filter(s.filter,nil,tp,rp):IsExists(s.cfilter,1,nil,tp,e:GetHandler():GetSequence())
end
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Group.FromCards(e:GetHandler()),1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.Destroy(e:GetHandler(),REASON_EFFECT)>0 then
		local val=Duel.Damage(tp,2000,REASON_EFFECT)
		if val>0 and Duel.GetLP(tp)>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,2000,REASON_EFFECT)
		end
	end
end
