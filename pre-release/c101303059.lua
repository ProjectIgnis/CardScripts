--スローン・オブ・デーモンズ
--Throne of Archfiends
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreater({handler=c,
		filter=s.ritualmonsterfilter,
		location=LOCATION_HAND|LOCATION_GRAVE|LOCATION_EXTRA|LOCATION_REMOVED})
	--Add this card from your GY or banishment to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,101303031),tp,LOCATION_EXTRA,0,1,nil) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_names={101303031} --"Doom Emperor Archfiend"
s.listed_series={SET_ARCHFIEND}
function s.ritualmonsterfilter(c)
	return c:IsSetCard(SET_ARCHFIEND) and c:IsRitualMonster() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end