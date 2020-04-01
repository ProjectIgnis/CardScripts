--武神器－マフツ
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.descon)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_series={0x88}
function s.cfilter(c,tp)
	return c:IsSetCard(0x88) and c:IsControler(tp) and c:IsPreviousControler(tp)
		and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.cfilter,nil,tp)
	e:SetLabelObject(g:GetFirst())
	return #g>0
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetReasonCard()
	if chk==0 then return tc:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetReasonCard()
	if tc:IsRelateToBattle() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
