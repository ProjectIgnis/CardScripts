--相対性フィールド
--Relativity Field
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--
	s.create_effect(c,0)
	s.create_effect(c,1)
end
function s.create_effect(c,p)
	--lose lp
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabel(Duel.GetLP(p))
	e2:SetCondition(s.lpcon(p))
	e2:SetOperation(s.lpop(p))
	c:RegisterEffect(e2)
	--lose atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_SZONE)
	e4:SetLabelObject(e2)
	e4:SetCondition(s.atkcon(p))
	e4:SetOperation(s.atkop(p))
	c:RegisterEffect(e4)
end
function s.lpcon(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return (Duel.GetLP(p)~=e:GetLabel() and not Duel.IsExistingTarget(Card.IsFaceup,p,LOCATION_MZONE,0,1,nil)) or Duel.GetLP(p)>e:GetLabel()
	end
end
function s.lpop(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		e:SetLabel(Duel.GetLP(p))
	end
end
function s.atkcon(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetLP(p)<e:GetLabelObject():GetLabel() and Duel.IsExistingTarget(Card.IsFaceup,p,LOCATION_MZONE,0,1,nil)
	end
end
function s.atkop(p)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local atk=e:GetLabelObject():GetLabel()-Duel.GetLP(p)
		e:GetLabelObject():SetLabel(Duel.GetLP(p))
		for tc in Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil):Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end