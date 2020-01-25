--ドカンポリン
--Boompoline!!
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--return to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)+Duel.GetLocationCount(tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)>0 end
	local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,0,true)
	Duel.Hint(HINT_ZONE,tp,zone)
	e:SetLabel(zone)
end
function s.thfilter(c,tp,zone)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and aux.IsZone(c,zone,tp) and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabelObject():GetLabel()
	return eg:IsExists(s.thfilter,1,nil,tp,zone)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local zone=e:GetLabelObject():GetLabel()
	local g=eg:Filter(s.thfilter,nil,tp,zone)
	g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=e:GetLabelObject():GetLabel()
	local g=eg:Filter(s.thfilter,nil,tp,zone)
	if c:IsRelateToEffect(e) and c:IsAbleToHand() and #g>0 then
		g:AddCard(c)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
