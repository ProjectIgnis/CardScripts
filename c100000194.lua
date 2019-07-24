--ダイス・クライシス
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)	
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)	
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function s.filter(c,tc)
	return c:IsControlerCanBeChanged()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	return tc
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.GetControl(tc,tc:GetOwner())
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()	
	if d==6 then 
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and c:IsLocation(LOCATION_SZONE) 
			and not tc:IsImmuneToEffect(e) then
				Duel.Equip(tp,c,tc)
				--Add Equip limit
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				e1:SetLabelObject(tc)
				c:RegisterEffect(e1)
				--destroy
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
				e2:SetRange(LOCATION_SZONE)
				e2:SetCode(EVENT_LEAVE_FIELD)	
				e2:SetCondition(s.descon)
				e2:SetOperation(s.desop)				
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e2)
				--Control
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_EQUIP)
				e3:SetCode(EFFECT_SET_CONTROL)
				e3:SetValue(tp)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				c:RegisterEffect(e3)
				--cannot attack
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_EQUIP)
				e4:SetCode(EFFECT_SET_ATTACK)
				e4:SetValue(0)				
				e4:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e4)
		end
	end
end