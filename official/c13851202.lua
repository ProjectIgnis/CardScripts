--星因士 リゲル
--Satellarknight Rigel
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 "tellarknight" monster on the field gain 500 ATK, but send it to the GY during the End Phase
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.atktg)
	e1a:SetOperation(s.atkop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	local e1c=e1a:Clone()
	e1c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1c)
end
s.listed_series={SET_TELLARKNIGHT}
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsSetCard(SET_TELLARKNIGHT) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_TELLARKNIGHT),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_TELLARKNIGHT),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsFaceup() then
			--It gains 500 ATK
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		--Send it to the GY during the End Phase
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,
			function(dg) Duel.SendtoGrave(dg,REASON_EFFECT) end,
			nil,0,1,aux.Stringid(id,1),aux.Stringid(id,2)
		)
	end
end