--地盤沈下
--Ground Collapse
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--disable field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetOperation(s.disop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>1 end
	local dis=Duel.SelectDisableField(tp,2,LOCATION_MZONE,LOCATION_MZONE,0)
	Duel.Hint(HINT_ZONE,tp,dis)
	e:SetLabel(dis)
end
function s.disop(e,tp)
	return e:GetLabelObject():GetLabel()
end
