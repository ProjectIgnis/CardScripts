--光のピラミッド
--Pyramid of Light
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Register when this card leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(s.checkop)
	c:RegisterEffect(e2)
	--Destroy and banish "Andro Sphinx" and "Sphinx Teleia you control
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_names={15013468,51402177} --"Andro Sphinx","Sphinx Teleia
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and not c:IsDisabled() then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabelObject():GetLabel()==1 and c:IsPreviousControler(tp) then
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,15013468,51402177),tp,LOCATION_ONFIELD,0,nil)
		if #g>0 then
			Duel.Hint(HINT_CARD,1-tp,id)
			Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
		end
	end
end