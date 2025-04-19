--鏡壁の石版
--Mirror Tablet
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabelObject(eg:GetFirst():GetReasonCard())
	return eg:IsExists(Card.IsPreviousControler,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bt=e:GetLabelObject()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_ATTACK)
		and bt:IsFaceup() and bt:IsControler(1-tp) and bt:IsRelateToBattle() end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local bt=e:GetLabelObject()
	if bt:IsFacedown() or bt:IsControler(tp) or not bt:IsRelateToBattle() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,LOCATION_MZONE,0,1,1,nil,POS_FACEUP_ATTACK):GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
		e1:SetValue(bt:GetAttack()/2)
		tc:RegisterEffect(e1)
		Duel.CalculateDamage(tc,bt)
	end
end