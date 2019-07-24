--Sky of Endless Night
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.filter(c,g)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and not g:IsContains(c)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.repfilter,nil,tp)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
	e:SetLabelObject(g)
	g:KeepAlive()
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	g:DeleteGroup()
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local xyz=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
		if #xyz>0 then
			Duel.HintSelection(xyz)
			Duel.Overlay(xyz:GetFirst(),g)
		end
	end
end
