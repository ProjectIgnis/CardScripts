--天装騎兵ガレア
--Armatos Legio Galea
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--linked group
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD_P)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.linkcon)
	e1:SetOperation(s.linkop)
	c:RegisterEffect(e1)
	--no dmg
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.ndamcon)
	e2:SetOperation(s.ndamop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
function s.linkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function s.linkfilter(c,e,tp)
	return c and c:IsLinkMonster() and c:IsSetCard(0x578) and c:IsFaceup() and c:IsControler(tp)
		and (e:GetHandler():GetLinkedGroup():IsContains(c) or c:GetLinkedGroup():IsContains(e:GetHandler()))
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	if #g>0 then
		e:SetLabelObject(g)
		e:SetLabel(1)
		local tc=g:GetFirst()
		while tc do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			tc=g:GetNext()
		end
	end
end
function s.ndamcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetLabelObject():GetLabel()==1
end
function s.ndamop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	if g and #g>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.efilter)
		e1:SetValue(1)
		e1:SetLabelObject(g)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.efilter(e,c)
	return c:GetFlagEffect(id)>0
end