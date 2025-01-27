--勇気の砂時計
--Hourglass of Courage
local s,id=GetID()
function s.initial_effect(c)
	--Original ATK and DEF are halved
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.atkdeftg)
	e1:SetOperation(s.atkdefop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.atkdeftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,e:GetHandler(),1,0,0)
end
function s.atkdefop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(s.atkval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(s.defval)
		c:RegisterEffect(e2)
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,Duel.IsTurnPlayer(tp) and 3 or 2)
	end
end
function s.atkval(e,c)
	if c:GetFlagEffect(id)==0 then
		return c:GetBaseAttack()*2
	else
		return c:GetBaseAttack()/2
	end
end
function s.defval(e,c)
	if c:GetFlagEffect(id)==0 then
		return c:GetBaseDefense()*2
	else
		return c:GetBaseDefense()/2
	end
end