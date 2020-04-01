--天装騎兵マジカ・アルクム
--Armatos Legio Magica Alcum
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--to GY and destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_series={0x578}
s.listed_names={511009503}
function s.tgfilter(c,e,tp)
	return c:IsCode(511009503) and c:IsFaceup() and c:GetSequence()<5 and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.linkedfilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler(),c)
end
function s.linkedfilter(c,mag_alc,j_arrows)
	return c:IsSetCard(0x578) and c:IsLinkMonster() and c:IsFaceup()
		and (mag_alc:GetLinkedGroup():IsContains(c) or c:GetLinkedGroup():IsContains(mag_alc))
		and c:GetLinkedGroup():IsContains(j_arrows)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsController(tp) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_SZONE,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSequence,0,1,2,3,4),tp,0,LOCATION_MZONE+LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	local desg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSequence,0,1,2,3,4),tp,0,LOCATION_MZONE+LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,LOCATION_SZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,desg,#desg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--cannot be destroyed by card effects this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x578))
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),0,tp,1,0,aux.Stringid(id,0),nil)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_GRAVE) then
		local desg=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSequence,0,1,2,3,4),tp,0,LOCATION_MZONE+LOCATION_SZONE,nil)
		Duel.Destroy(desg,REASON_EFFECT)
	end
end